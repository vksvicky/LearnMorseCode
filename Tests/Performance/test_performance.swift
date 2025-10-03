#!/usr/bin/env swift

import Foundation

// Performance test for Morse code conversion
// This script tests conversion performance with various input sizes

print("🚀 Morse Code Performance Test Suite")
print("=====================================")

// Test data of various sizes
let testCases = [
    ("Small (1 line)", "Hello World"),
    ("Medium (5 lines)", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 5)),
    ("Large (10 lines)", String(repeating: "Pack my box with five dozen liquor jugs. ", count: 10)),
    ("Very Large (20 lines)", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 20)),
    ("Extreme (50 lines)", String(repeating: "Pack my box with five dozen liquor jugs. ", count: 50))
]

// Simple Morse encoder for testing (simplified version)
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

// Performance measurement function
func measureTime<T>(_ operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return (result, timeElapsed)
}

// Test encoding performance
print("\n📊 Text to Morse Encoding Performance:")
print("--------------------------------------")

let encoder = SimpleMorseEncoder()

for (description, text) in testCases {
    let (result, time) = measureTime {
        encoder.encode(text)
    }
    
    let inputLength = text.count
    let outputLength = result.count
    let compressionRatio = Double(outputLength) / Double(inputLength)
    
    print("\(description):")
    print("  Input: \(inputLength) characters")
    print("  Output: \(outputLength) characters")
    print("  Time: \(String(format: "%.3f", time))s")
    print("  Compression: \(String(format: "%.2f", compressionRatio))x")
    print("  Speed: \(String(format: "%.0f", Double(inputLength) / time)) chars/sec")
    
    if time > 1.0 {
        print("  ⚠️  SLOW: Conversion took over 1 second")
    } else if time > 0.1 {
        print("  ⚠️  MODERATE: Conversion took over 100ms")
    } else {
        print("  ✅ FAST: Conversion under 100ms")
    }
    print()
}

// Test with problematic inputs
print("🔍 Problematic Input Tests:")
print("---------------------------")

let problematicInputs = [
    ("Repeated text", String(repeating: "HELLO", count: 100)),
    ("Long single word", String(repeating: "SUPERCALIFRAGILISTICEXPIALIDOCIOUS", count: 10)),
    ("Mixed case", "HeLLo WoRLd ThIs Is A TeSt"),
    ("Numbers and punctuation", "1234567890!@#$%^&*()"),
    ("Very long line", String(repeating: "A", count: 1000))
]

for (description, text) in problematicInputs {
    let (result, time) = measureTime {
        encoder.encode(text)
    }
    
    print("\(description): \(String(format: "%.3f", time))s")
    if time > 0.5 {
        print("  ⚠️  PERFORMANCE ISSUE DETECTED")
    }
}

print("\n🎯 Performance Recommendations:")
print("-------------------------------")
print("1. Add input size limits (e.g., max 1000 characters)")
print("2. Implement chunked processing for large inputs")
print("3. Add progress indicators for long conversions")
print("4. Use background processing for large conversions")
print("5. Cache frequently used conversions")
print("6. Optimize string operations and reduce allocations")

print("\n✅ Performance test completed!")
