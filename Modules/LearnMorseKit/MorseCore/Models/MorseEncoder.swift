import Foundation

public enum MorseEncodingError: Error, Equatable {
    case unsupportedCharacter(Character)
}

public protocol MorseEncoding {
    func encode(_ text: String) throws -> String
}

public struct MorseEncoder: MorseEncoding {
    public init() {}

    private let map: [Character: String] = [
        // Letters
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--", "Z": "--..",
        // Numbers
        "0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
        "5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----.",
        // Punctuation
        ".": ".-.-.-", ",": "--..--", "?": "..--..", "'": ".----.", "!": "-.-.--",
        "/": "-..-.", "(": "-.--.", ")": "-.--.-", "&": ".-...", ":": "---...",
        ";": "-.-.-.", "=": "-...-", "+": ".-.-.", "-": "-....-", "_": "..--.-",
        "\"": ".-..-.", "$": "...-..-", "@": ".--.-."
    ]

    public func encode(_ text: String) throws -> String {
        if text.isEmpty { return "" }

        let words = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        guard !words.isEmpty else { return "/" }

        let encoded = try words.map { word -> String in
            try word.uppercased().map { ch -> String in
                guard let code = map[ch] else { throw MorseEncodingError.unsupportedCharacter(ch) }
                return code
            }.joined(separator: " ")
        }.joined(separator: " / ")

        return encoded
    }
}
