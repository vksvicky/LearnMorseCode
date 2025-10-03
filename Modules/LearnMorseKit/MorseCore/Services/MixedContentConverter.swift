import Foundation

/// A service for handling mixed content conversion (Morse code + text)
public class MixedContentConverter {
    
    public init() {}
    
    /// Converts mixed content (Morse code + text) to Morse code
    /// - Parameter text: Input containing both Morse code and text
    /// - Returns: Properly formatted Morse code
    /// - Throws: MorseEncodingError or MorseDecodingError if conversion fails
    public func convertMixedContent(_ text: String) throws -> String {
        // Parse mixed content: separate Morse code from text and handle appropriately
        var result: [String] = []
        var currentText = ""
        var currentMorse = ""
        
        for char in text {
            if char == "." || char == "-" || char == "/" {
                // This is a Morse character
                if !currentText.isEmpty {
                    // Convert accumulated text to Morse
                    let morseWord = try MorseEncoder().encode(currentText)
                    result.append(morseWord)
                    currentText = ""
                }
                currentMorse.append(char)
            } else if char == " " {
                // Space can be part of Morse code or separator
                if !currentMorse.isEmpty {
                    // If we're in Morse mode, add the space
                    currentMorse.append(char)
                } else if !currentText.isEmpty {
                    // If we're in text mode, add the space
                    currentText.append(char)
                }
                // If both are empty, ignore the space
            } else {
                // This is a text character
                if !currentMorse.isEmpty {
                    // Handle accumulated Morse code (trim trailing spaces)
                    let morseResult = try handleMorseCode(currentMorse.trimmingCharacters(in: .whitespaces))
                    result.append(morseResult)
                    currentMorse = ""
                }
                currentText.append(char)
            }
        }
        
        // Handle any remaining content
        if !currentText.isEmpty {
            let morseWord = try MorseEncoder().encode(currentText)
            result.append(morseWord)
        }
        
        if !currentMorse.isEmpty {
            let morseResult = try handleMorseCode(currentMorse.trimmingCharacters(in: .whitespaces))
            result.append(morseResult)
        }
        
        return result.joined(separator: " ")
    }
    
    private func handleMorseCode(_ morse: String) throws -> String {
        let trimmedMorse = morse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it's empty, return empty
        if trimmedMorse.isEmpty {
            return ""
        }
        
        // Try to decode the Morse code
        do {
            let decodedText = try MorseDecoder().decode(trimmedMorse)
            // If decoding succeeds, convert the decoded text back to Morse
            return try MorseEncoder().encode(decodedText)
        } catch {
            // If decoding fails, pass the Morse code through as-is
            // This handles cases where the Morse code is valid but can't be decoded
            return trimmedMorse
        }
    }
}
