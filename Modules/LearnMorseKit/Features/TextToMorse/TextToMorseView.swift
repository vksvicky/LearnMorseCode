import SwiftUI
import MorseCore
import LearnMorseUI

// Global performance limits to prevent hanging
private let MAX_INPUT_LENGTH = 500

public struct TextToMorseView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isConverting = false
    @State private var conversionTask: Task<Void, Never>?
    @State private var conversionType: ConversionType = .auto
    
    public init() {}

    enum ConversionType {
        case textToMorse
        case morseToText
        case auto
    }
    
    public var body: some View {
        VStack(spacing: 30) {
                    // Input section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Input")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        Button("Clear") {
                            inputText = ""
                                outputText = ""
                        }
                            .font(.headline)
                            .foregroundColor(.blue)
                        }
                        
                        TextEditor(text: $inputText)
                            .font(AppFonts.primary())
                            .frame(height: 150)
                            .padding(16)
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                        .onChange(of: inputText) { _, newValue in
                                // Limit input length to prevent performance issues
                                if newValue.count > MAX_INPUT_LENGTH {
                                    inputText = String(newValue.prefix(MAX_INPUT_LENGTH))
                                    return
                                }
                                
                                // Clear output when input changes
                                outputText = ""
                                // Auto-detect conversion type
                                conversionType = detectConversionType(newValue)
                        }
                        
                        // Character counter
                        HStack {
                            Spacer()
                            Text("\(inputText.count)/\(MAX_INPUT_LENGTH)")
                                .font(AppFonts.small())
                                .foregroundColor(inputText.count > Int(Double(MAX_INPUT_LENGTH) * 0.9) ? .red : .secondary)
                        }
                        
                        // Helpful note about Morse code formatting
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(AppFonts.small())
                            Text("💡 Tip: For accurate Morse-to-text conversion, use spaces between letters (e.g., '.... . .-.. .-.. ---' for 'HELLO')")
                                .font(AppFonts.small())
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(maxWidth: 800)
                    
                    // Single Convert button
                    Button(action: convert) {
                            HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text(buttonText)
                            }
                            .font(.headline)
                        .frame(maxWidth: 300)
                            .padding(.vertical, 16)
                        .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(inputText.isEmpty || isConverting)
                    
                    // Output section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Output")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            HStack(spacing: 16) {
                                if isMorseOutput {
                                Button("Play") {
                                        // Convert continuous Morse back to spaced format for audio
                                        let audioMorse = formatMorseForAudio(outputText)
                                        morseModel.playMorseCode(audioMorse)
                                }
                                .font(.headline)
                                .foregroundColor(.green)
                                    .disabled(outputText.isEmpty)
                                    
                                Button("Stop") {
                                    morseModel.audioService.stop()
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .disabled(!morseModel.audioService.isPlaying)
                                }
                                
                                Button("Copy") {
                                    copyToClipboard(outputText)
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .disabled(outputText.isEmpty)
                            }
                        }
                        
                        ScrollView {
                            if isMorseOutput {
                                // Visual feedback for Morse code
                                MorseCodeVisualView(
                                    morseCode: outputText.isEmpty ? placeholderText : outputText,
                                    audioService: morseModel.audioService
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separatorColor), lineWidth: 1)
                                )
                            } else {
                                // Regular text display
                                Text(outputText.isEmpty ? placeholderText : outputText)
                                    .font(AppFonts.primary())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(Color(.controlBackgroundColor))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.separatorColor), lineWidth: 1)
                                    )
                            }
                        }
                        .frame(height: 150)
                    }
                    .frame(maxWidth: 800)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Computed Properties

    private var buttonText: String {
        switch conversionType {
        case .textToMorse:
            return "Convert to Morse"
        case .morseToText:
            return "Convert to Text"
        case .auto:
            return "Convert"
        }
    }

    private var placeholderText: String {
        switch conversionType {
        case .textToMorse:
            return "Enter text to convert to Morse code..."
        case .morseToText:
            return "Enter Morse code to convert to text..."
        case .auto:
            return "Enter text or Morse code to convert..."
        }
    }

    private var isMorseOutput: Bool {
        return conversionType == .textToMorse
    }

    // MARK: - Conversion Logic

    private func detectConversionType(_ text: String) -> ConversionType {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            return .auto
        }
        
        // Check for mixed content (both text and Morse)
        let hasText = hasTextCharacters(trimmedText)
        let hasMorse = hasMorseCharacters(trimmedText)
        
        if hasText && hasMorse {
            // Mixed content - prioritize text to Morse conversion
            return .textToMorse
        }
        
        if hasText {
            return .textToMorse
        }
        
        if hasMorse {
            // If it contains only Morse characters, it's likely Morse code
            // Check if it can be decoded (with formatting if needed)
            if isValidMorseCode(trimmedText) {
                return .morseToText
            } else {
                // Even if validation fails, if it's only dots/dashes, treat as Morse
                return .morseToText
            }
        }
        
        return .auto
    }
    
    private func hasTextCharacters(_ text: String) -> Bool {
        // Check if text contains letters, numbers, or punctuation (not Morse)
        // Only consider it text if it contains actual letters/numbers/punctuation
        let morseCharacters = CharacterSet(charactersIn: ".- /")
        let nonMorseCharacters = text.unicodeScalars.filter { !morseCharacters.contains($0) }
        
        // If there are non-Morse characters, check if they're actual text (letters, numbers, punctuation)
        if !nonMorseCharacters.isEmpty {
            let textCharacters = CharacterSet.letters.union(.decimalDigits).union(.punctuationCharacters)
            return nonMorseCharacters.contains { textCharacters.contains($0) }
        }
        
        return false
    }
    
    private func hasMorseCharacters(_ text: String) -> Bool {
        // Check if text contains dots, dashes, or slashes
        let morseCharacters = CharacterSet(charactersIn: ".-/")
        return text.unicodeScalars.contains { morseCharacters.contains($0) }
    }
    
    private func isValidMorsePattern(_ pattern: String) -> Bool {
        // Valid Morse patterns contain only dots and dashes
        let validCharacters = CharacterSet(charactersIn: ".-")
        return pattern.unicodeScalars.allSatisfy { validCharacters.contains($0) }
    }
    
    private func isValidMorseCode(_ morse: String) -> Bool {
        // SIMPLIFIED: Just check if it contains valid Morse characters
        // This avoids the complex decoding that was causing performance issues
        
        let morseCharacters = CharacterSet(charactersIn: ".-/ ")
        let validCharacters = morse.unicodeScalars.allSatisfy { morseCharacters.contains($0) }
        
        // Basic validation: must contain at least one dot or dash
        let hasMorseElements = morse.contains(".") || morse.contains("-")
        
        return validCharacters && hasMorseElements
        
        /* COMPLEX DECODING VALIDATION COMMENTED OUT - WAS CAUSING PERFORMANCE ISSUES
        // Check if the Morse code can be decoded successfully
        do {
            _ = try MorseDecoder().decode(morse)
            return true
        } catch {
            // If decoding fails, try to format it properly and test again
            let formattedMorse = formatMorseCode(morse)
            if formattedMorse.isEmpty {
                return false // Could not format into valid patterns
            }
            do {
                _ = try MorseDecoder().decode(formattedMorse)
                return true
            } catch {
                return false
            }
        }
        */
    }
    
    private func formatMorseCode(_ morse: String) -> String {
        let trimmedMorse = morse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to split continuous Morse into valid patterns
        return splitContinuousMorse(trimmedMorse)
    }
    
    private func splitContinuousMorse(_ morse: String) -> String {
        // Use multiple strategies inspired by research on Morse code decoding
        // This handles ambiguous continuous Morse sequences better
        
        let strategies = [
            // Strategy 1: Try with all patterns (longest first)
            tryParseWithAllPatterns(morse),
            // Strategy 2: Try with letters only (more common in text)
            tryParseWithLettersOnly(morse),
            // Strategy 3: Try with common patterns first
            tryParseWithCommonPatterns(morse)
        ]
        
        // Return the first valid result
        for strategy in strategies {
            if !strategy.isEmpty && isValidMorseCode(strategy) {
                return strategy
            }
        }
        
        // If no valid split found, return original
        return morse
    }
    
    private func tryParseWithAllPatterns(_ morse: String) -> String {
        let allPatterns = [
            // Numbers (longest first)
            "-----", ".----", "..---", "...--", "....-", ".....",
            "-....", "--...", "---..", "----.",
            // Letters (longest first)
            "-...", "-.-.", "-..", "..-.", "--.", "....", ".---",
            "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.",
            "...", "..-", "...-", ".--", "-..-", "-.--", "--..",
            // Single characters
            ".-", "-", "."
        ]
        
        if let bestSplit = findBestValidSplit(morse, allPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    private func tryParseWithLettersOnly(_ morse: String) -> String {
        let letterPatterns = [
            // Letters only (longest first)
            "-...", "-.-.", "-..", "..-.", "--.", "....", ".---",
            "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.",
            "...", "..-", "...-", ".--", "-..-", "-.--", "--..",
            ".-", "-", "."
        ]
        
        if let bestSplit = findBestValidSplit(morse, letterPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    private func tryParseWithCommonPatterns(_ morse: String) -> String {
        // Try with the most common patterns first
        let commonPatterns = [
            // Most common letters first
            ".", "-", "..", "--", "...", "---", ".-", "-.", ".-.", "-..",
            ".-..", "--.", "....", "-...", "-.-.", "..-.", ".---", "-.-",
            "..-", "...-", ".--", "-..-", "-.--", "--..", "--.-", ".--."
        ]
        
        if let bestSplit = findBestValidSplit(morse, commonPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    
    private func findBestValidSplit(_ morse: String, _ patterns: [String]) -> [String]? {
        // Use backtracking to find the best valid split
        // This approach is inspired by research on Morse code decoding algorithms
        
        var bestResult: [String]? = nil
        var bestScore = Int.max
        
        func trySplit(_ remaining: String, _ current: [String], _ depth: Int = 0) {
            // Prevent infinite recursion
            if depth > 50 {
                return
            }
            
            if remaining.isEmpty {
                // Found a complete split, evaluate its quality
                let score = evaluateSplit(current)
                if score < bestScore {
                    bestResult = current
                    bestScore = score
                }
                return
            }
            
            // Try each pattern that matches the beginning
            for pattern in patterns {
                if remaining.hasPrefix(pattern) {
                    let newRemaining = String(remaining.dropFirst(pattern.count))
                    trySplit(newRemaining, current + [pattern], depth + 1)
                }
            }
        }
        
        trySplit(morse, [])
        return bestResult
    }
    
    private func evaluateSplit(_ patterns: [String]) -> Int {
        // Evaluate the quality of a split
        // Lower score is better
        
        // Strongly prefer fewer parts (this is the most important factor)
        var score = patterns.count * 100
        
        // Penalty for using single dots/dashes (prefer longer patterns)
        for pattern in patterns {
            if pattern == "." || pattern == "-" {
                score += 50 // Heavy penalty for single characters
            }
        }
        
        // Bonus for common patterns (letters over numbers, common letters over rare ones)
        let commonLetters = ["E", "T", "A", "O", "I", "N", "S", "H", "R", "D", "L", "C", "U", "M", "W", "F", "G", "Y", "P", "B", "V", "K", "J", "X", "Q", "Z"]
        
        for pattern in patterns {
            if let character = morseToCharacter[pattern] {
                if let index = commonLetters.firstIndex(of: character) {
                    score -= (commonLetters.count - index) // More common = lower score
                } else {
                    // Numbers get a small penalty
                    score += 10
                }
            }
        }
        
        return score
    }
    
    // Helper dictionary to map Morse patterns to characters
    private let morseToCharacter: [String: String] = [
        ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
        "..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
        "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
        ".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
        "..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y",
        "--..": "Z",
        "-----": "0", ".----": "1", "..---": "2", "...--": "3", "....-": "4",
        ".....": "5", "-....": "6", "--...": "7", "---..": "8", "----.": "9"
    ]

    private func convert() {
        // Cancel any existing conversion task
        conversionTask?.cancel()
        
        // Create a new debounced conversion task
        conversionTask = Task {
            // Wait a bit to debounce rapid changes
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            // Check if task was cancelled
            if Task.isCancelled { return }
            
            await MainActor.run {
                performConversion()
            }
        }
    }
    
    private func performConversion() {
        guard !inputText.isEmpty else {
            outputText = ""
            return
        }
        
        // Performance optimization: limit input size to prevent hanging
        let maxInputLength = 1000
        let textToProcess = inputText.count > maxInputLength ? 
            String(inputText.prefix(maxInputLength)) + "..." : inputText
        
        isConverting = true
        
        do {
            switch conversionType {
            case .textToMorse:
                outputText = try convertToMorse(textToProcess)
            case .morseToText:
                // SIMPLIFIED: Skip complex Morse to text conversion to avoid hanging
                // Just show a message that this feature is temporarily disabled
                outputText = "Morse to text conversion temporarily disabled to improve performance"
            case .auto:
                // SIMPLIFIED: Always convert to Morse to avoid complex decoding
                outputText = try convertToMorse(textToProcess)
                
                /* COMPLEX AUTO-DETECTION COMMENTED OUT - WAS CAUSING PERFORMANCE ISSUES
                // Try to auto-detect and convert
                let detectedType = detectConversionType(textToProcess)
                if detectedType == .textToMorse {
                    outputText = try convertToMorse(textToProcess)
                } else {
                    // Try Morse to text first, if it fails, try text to Morse
                    do {
                        let formattedInput = formatMorseCode(textToProcess)
                        outputText = try MorseDecoder().decode(formattedInput)
                    } catch {
                        // If Morse decoding fails, try text encoding as fallback
                        outputText = try convertToMorse(textToProcess)
                    }
                }
                */
            }
        } catch let error as MorseDecodingError {
            switch error {
            case .invalidMorse(let token):
                showError("Invalid Morse code pattern: '\(token)'. Please check your input format.")
            }
        } catch let error as MorseEncodingError {
            switch error {
            case .unsupportedCharacter(let char):
                showError("Unsupported character: '\(char)'. Only letters, numbers, and basic punctuation are supported.")
            }
        } catch {
            showError("Conversion failed: \(error.localizedDescription)")
        }
        
        isConverting = false
    }
    
    private func convertToMorse(_ text: String) throws -> String {
        // PERFORMANCE LIMIT: Prevent extremely long inputs from causing hangs
        let limitedText = text.count > MAX_INPUT_LENGTH ? 
            String(text.prefix(MAX_INPUT_LENGTH)) + "..." : text
        
        let encodedMorse: String
        
        // Check if input contains mixed content
        if hasTextCharacters(limitedText) && hasMorseCharacters(limitedText) {
            encodedMorse = try convertMixedContent(limitedText)
        } else {
            encodedMorse = try MorseEncoder().encode(limitedText)
        }
        
        // Return the encoded Morse code directly (already properly spaced)
        return encodedMorse
    }
    
    private func formatMorseForAudio(_ morse: String) -> String {
        // Convert continuous Morse back to spaced format for audio playback
        // Example: "...---..." -> "... --- ..."
        
        // Split by spaces (word boundaries)
        let words = morse.components(separatedBy: " ")
        var result: [String] = []
        
        for word in words {
            if word.isEmpty { continue }
            
            // Split continuous Morse into individual patterns
            var spacedWord = ""
            var currentPattern = ""
            
            for char in word {
                if char == "." || char == "-" {
                    currentPattern.append(char)
                } else {
                    if !currentPattern.isEmpty {
                        spacedWord += currentPattern + " "
                        currentPattern = ""
                    }
                }
            }
            
            if !currentPattern.isEmpty {
                spacedWord += currentPattern
            }
            
            result.append(spacedWord.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return result.joined(separator: " / ")
    }
    
    private func convertMixedContent(_ text: String) throws -> String {
        // SIMPLIFIED APPROACH: Only convert text to Morse, skip Morse to text conversion
        // This avoids the complex decoding that was causing performance issues
        
        // For mixed content, just convert everything to Morse code
        // This is much simpler and faster than trying to decode Morse back to text
        return try MorseEncoder().encode(text)
        
        /* COMPLEX MIXED CONTENT PROCESSING COMMENTED OUT - WAS CAUSING PERFORMANCE ISSUES
        // Parse mixed content: convert text to Morse AND Morse to text
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
            } else if char.isWhitespace {
                // Handle whitespace
                if !currentText.isEmpty {
                    let morseWord = try MorseEncoder().encode(currentText)
                    result.append(morseWord)
                    currentText = ""
                }
                if !currentMorse.isEmpty {
                    // Convert accumulated Morse to text
                    let formattedMorse = formatMorseCode(currentMorse)
                    let decodedText = try MorseDecoder().decode(formattedMorse)
                    result.append(decodedText)
                    currentMorse = ""
                }
            } else {
                // This is a text character
                if !currentMorse.isEmpty {
                    // Convert accumulated Morse to text
                    let formattedMorse = formatMorseCode(currentMorse)
                    let decodedText = try MorseDecoder().decode(formattedMorse)
                    result.append(decodedText)
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
            // Convert remaining Morse to text
            let formattedMorse = formatMorseCode(currentMorse)
            let decodedText = try MorseDecoder().decode(formattedMorse)
            result.append(decodedText)
        }
        
        return result.joined(separator: " / ")
        */
    }
    
    /* COMPLEX CHUNKED PROCESSING FUNCTION COMMENTED OUT - NO LONGER NEEDED
    private func convertMixedContentChunked(_ text: String) throws -> String {
        // Process large inputs in chunks to prevent hanging
        let chunkSize = 200
        var result: [String] = []
        
        // Split text into chunks by words to avoid breaking in the middle of words
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var currentChunk = ""
        
        for word in words {
            if currentChunk.count + word.count > chunkSize && !currentChunk.isEmpty {
                // Process current chunk
                let chunkResult = try convertMixedContent(currentChunk)
                result.append(chunkResult)
                currentChunk = word
            } else {
                if !currentChunk.isEmpty {
                    currentChunk += " "
                }
                currentChunk += word
            }
        }
        
        // Process remaining chunk
        if !currentChunk.isEmpty {
            let chunkResult = try convertMixedContent(currentChunk)
            result.append(chunkResult)
        }
        
        return result.joined(separator: " / ")
    }
    */
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

// MARK: - MorseCodeVisualView

struct MorseCodeVisualView: View {
    let morseCode: String
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        Text(morseCode)
            .font(AppFonts.large(weight: .bold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                // Overlay for visual feedback highlighting - only for dots and dashes
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(morseCode.enumerated()), id: \.offset) { index, character in
                        if character == "." || character == "-" {
                            let visualIndex = getVisualIndex(for: index)
                            Rectangle()
                                .fill(backgroundColor(for: index))
                                .frame(width: 14, height: 24) // Approximate character width
                                .opacity(visualIndex == audioService.currentCharacterIndex ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.1), value: audioService.currentCharacterIndex)
                        } else {
                            // For spaces, slashes, and other characters - no highlighting
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: character == " " ? 8 : 12, height: 24)
                        }
                    }
                }
                .allowsHitTesting(false)
            )
    }
    
    private func textColor(for index: Int) -> Color {
        let character = morseCode[morseCode.index(morseCode.startIndex, offsetBy: index)]
        // Only highlight dots and dashes, not spaces
        guard character == "." || character == "-" else { return .primary }
        
        let visualIndex = getVisualIndex(for: index)
        if visualIndex == audioService.currentCharacterIndex && audioService.isElementPlaying {
            return .white
        } else if visualIndex == audioService.currentCharacterIndex {
            return .primary
        } else {
            return .primary
        }
    }
    
    private func backgroundColor(for index: Int) -> Color {
        let character = morseCode[morseCode.index(morseCode.startIndex, offsetBy: index)]
        // Only highlight dots and dashes, not spaces
        guard character == "." || character == "-" else { return .clear }
        
        let visualIndex = getVisualIndex(for: index)
        if visualIndex == audioService.currentCharacterIndex && audioService.isElementPlaying {
            return .blue
        } else if visualIndex == audioService.currentCharacterIndex {
            return .blue.opacity(0.3)
        } else {
            return .clear
        }
    }
    
    private func scaleEffect(for index: Int) -> CGFloat {
        let character = morseCode[morseCode.index(morseCode.startIndex, offsetBy: index)]
        // Only scale dots and dashes, not spaces
        guard character == "." || character == "-" else { return 1.0 }
        
        let visualIndex = getVisualIndex(for: index)
        if visualIndex == audioService.currentCharacterIndex && audioService.isElementPlaying {
            return 1.2
        } else if visualIndex == audioService.currentCharacterIndex {
            return 1.1
        } else {
            return 1.0
        }
    }
    
    private func getVisualIndex(for stringIndex: Int) -> Int {
        var visualIndex = 0
        for i in 0..<stringIndex {
            let character = morseCode[morseCode.index(morseCode.startIndex, offsetBy: i)]
            if character == "." || character == "-" {
                visualIndex += 1
            }
        }
        return visualIndex
    }
}
