import Foundation

public enum MorseDecodingError: Error, Equatable {
    case invalidMorse(String)
}

public struct MorseDecoder {
    public init() {}

    private let reverse: [String: Character] = [
        // Letters
        ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
        "..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
        "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
        ".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
        "..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y", "--..": "Z",
        // Numbers
        "-----": "0", ".----": "1", "..---": "2", "...--": "3", "....-": "4",
        ".....": "5", "-....": "6", "--...": "7", "---..": "8", "----.": "9",
        // Punctuation
        ".-.-.-": ".", "--..--": ",", "..--..": "?", ".----.": "'", "-.-.--": "!",
        "-..-.": "/", "-.--.": "(", "-.--.-": ")", ".-...": "&", "---...": ":",
        "-.-.-.": ";", "-...-": "=", ".-.-.": "+", "-....-": "-", "..--.-": "_",
        ".-..-.": "\"", "...-..-": "$", ".--.-.": "@"
    ]

    public func decode(_ morse: String) throws -> String {
        if morse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "" }

        let words = morse
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let decodedWords: [String] = try words.map { word in
            let letters = word.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let decodedLetters: [Character] = try letters.map { token in
                guard let ch = reverse[token] else { throw MorseDecodingError.invalidMorse(token) }
                return ch
            }
            return String(decodedLetters)
        }
        return decodedWords.joined(separator: " ")
    }
}
