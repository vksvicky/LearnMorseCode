#!/usr/bin/env swift

import Foundation

print("🚀 Comprehensive Morse Code Performance Test")
print("=============================================")

// Test data of various sizes
let testCases = [
    ("1 line", "Hello World"),
    ("3 lines", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 3)),
    ("5 lines", String(repeating: "Pack my box with five dozen liquor jugs. ", count: 5)),
    ("10 lines", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 10)),
    ("15 lines", String(repeating: "Pack my box with five dozen liquor jugs. ", count: 15)),
    ("20 lines", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 20))
]

// Morse patterns for decoding tests
let morseTestCases = [
    ("Simple", ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."),
    ("Medium", ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / - .... .. ... / .. ... / .- / - . ... -"),
    ("Complex", ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / - .... .. ... / .. ... / .- / - . ... - / --- ..-. / -- --- .-. ... . / -.-. --- -.. ."),
    ("Long", String(repeating: ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / ", count: 10)),
    ("Very Long", String(repeating: ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / ", count: 20))
]

// Performance measurement
func measureTime<T>(_ operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return (result, timeElapsed)
}

// Test encoding performance
print("\n📊 TEXT TO MORSE ENCODING PERFORMANCE:")
print("======================================")

struct SimpleMorseEncoder {
    private let map: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--", "Z": "--..",
        "0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
        "5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----.",
        ".": ".-.-.-", ",": "--..--", "?": "..--..", "'": ".----.", "!": "-.-.--",
        "/": "-..-.", "(": "-.--.", ")": "-.--.-", "&": ".-...", ":": "---...",
        ";": "-.-.-.", "=": "-...-", "+": ".-.-.", "-": "-....-", "_": "..--.-",
        "\"": ".-..-.", "$": "...-..-", "@": ".--.-."
    ]
    
    func encode(_ text: String) -> String {
        if text.isEmpty { return "" }
        
        let words = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        guard !words.isEmpty else { return "/" }
        
        let encoded = words.map { word -> String in
            word.uppercased().compactMap { ch -> String? in
                return map[ch]
            }.joined(separator: " ")
        }.joined(separator: " / ")
        
        return encoded
    }
}

let encoder = SimpleMorseEncoder()

for (description, text) in testCases {
    let (result, time) = measureTime {
        encoder.encode(text)
    }
    
    let inputLength = text.count
    let outputLength = result.count
    
    print("\(description):")
    print("  Input: \(inputLength) characters")
    print("  Output: \(outputLength) characters")
    print("  Time: \(String(format: "%.3f", time))s")
    print("  Speed: \(String(format: "%.0f", Double(inputLength) / time)) chars/sec")
    
    if time > 1.0 {
        print("  ❌ CRITICAL: Conversion took over 1 second")
    } else if time > 0.5 {
        print("  ⚠️  SLOW: Conversion took over 500ms")
    } else if time > 0.1 {
        print("  ⚠️  MODERATE: Conversion took over 100ms")
    } else {
        print("  ✅ FAST: Conversion under 100ms")
    }
    print()
}

// Test decoding performance
print("\n📊 MORSE TO TEXT DECODING PERFORMANCE:")
print("======================================")

struct SimpleMorseDecoder {
    private let reverse: [String: Character] = [
        ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
        "..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
        "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
        ".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
        "..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y", "--..": "Z",
        "-----": "0", ".----": "1", "..---": "2", "...--": "3", "....-": "4",
        ".....": "5", "-....": "6", "--...": "7", "---..": "8", "----.": "9",
        ".-.-.-": ".", "--..--": ",", "..--..": "?", ".----.": "'", "-.-.--": "!",
        "-..-.": "/", "-.--.": "(", "-.--.-": ")", ".-...": "&", "---...": ":",
        "-.-.-.": ";", "-...-": "=", ".-.-.": "+", "-....-": "-", "..--.-": "_",
        ".-..-.": "\"", "...-..-": "$", ".--.-.": "@"
    ]
    
    func decode(_ morse: String) -> String {
        if morse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "" }
        
        let words = morse
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let decodedWords: [String] = words.map { word in
            let letters = word.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let decodedLetters: [Character] = letters.compactMap { token in
                return reverse[token]
            }
            return String(decodedLetters)
        }
        return decodedWords.joined(separator: " ")
    }
}

let decoder = SimpleMorseDecoder()

for (description, morse) in morseTestCases {
    let (result, time) = measureTime {
        decoder.decode(morse)
    }
    
    let inputLength = morse.count
    let outputLength = result.count
    
    print("\(description):")
    print("  Input: \(inputLength) characters")
    print("  Output: \(outputLength) characters")
    print("  Time: \(String(format: "%.3f", time))s")
    print("  Speed: \(String(format: "%.0f", Double(inputLength) / time)) chars/sec")
    
    if time > 1.0 {
        print("  ❌ CRITICAL: Conversion took over 1 second")
    } else if time > 0.5 {
        print("  ⚠️  SLOW: Conversion took over 500ms")
    } else if time > 0.1 {
        print("  ⚠️  MODERATE: Conversion took over 100ms")
    } else {
        print("  ✅ FAST: Conversion under 100ms")
    }
    print()
}

// Test problematic scenarios
print("\n🔍 PROBLEMATIC SCENARIOS:")
print("=========================")

let problematicCases = [
    ("Repeated text", String(repeating: "HELLO WORLD ", count: 50)),
    ("Very long single word", String(repeating: "SUPERCALIFRAGILISTICEXPIALIDOCIOUS", count: 20)),
    ("Mixed case", String(repeating: "HeLLo WoRLd ThIs Is A TeSt ", count: 30)),
    ("Numbers and punctuation", String(repeating: "1234567890!@#$%^&*() ", count: 20)),
    ("Continuous Morse", String(repeating: ".... . .-.. .-.. ---", count: 50))
]

for (description, text) in problematicCases {
    let (_, time) = measureTime {
        encoder.encode(text)
    }
    
    print("\(description): \(String(format: "%.3f", time))s")
    if time > 1.0 {
        print("  ❌ CRITICAL PERFORMANCE ISSUE")
    } else if time > 0.5 {
        print("  ⚠️  PERFORMANCE ISSUE DETECTED")
    }
}

print("\n🎯 PERFORMANCE ANALYSIS:")
print("========================")
print("✅ Encoding: Simple and fast")
print("❌ Decoding: May have complexity issues")
print("❌ Mixed content: Character-by-character processing")
print("❌ Large inputs: No chunking or limits")

print("\n🔧 RECOMMENDED FIXES:")
print("=====================")
print("1. Add input size limits (1000 chars max)")
print("2. Implement chunked processing for large inputs")
print("3. Add progress indicators for long operations")
print("4. Use background processing for conversions > 100ms")
print("5. Cache frequently used patterns")
print("6. Optimize string operations")

print("\n✅ Performance test completed!")
