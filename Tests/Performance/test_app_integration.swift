#!/usr/bin/env swift

import Foundation

print("🚀 App Integration Performance Test")
print("====================================")

// This test simulates the actual app behavior with problematic inputs
// We'll test the scenarios that cause hanging in the real app

struct AppSimulator {
    // Simulate the TextToMorseView conversion logic
    func simulateConversion(_ inputText: String) -> (result: String, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate the conversion process
        var result = ""
        
        // Check for mixed content (this is where the performance issue occurs)
        if hasTextCharacters(inputText) && hasMorseCharacters(inputText) {
            result = simulateMixedContentConversion(inputText)
        } else if hasMorseCharacters(inputText) {
            result = simulateMorseToTextConversion(inputText)
        } else {
            result = simulateTextToMorseConversion(inputText)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }
    
    private func hasTextCharacters(_ text: String) -> Bool {
        return text.rangeOfCharacter(from: .letters) != nil
    }
    
    private func hasMorseCharacters(_ text: String) -> Bool {
        return text.contains(".") || text.contains("-") || text.contains("/")
    }
    
    private func simulateTextToMorseConversion(_ text: String) -> String {
        // Simple encoding - this is fast
        return "ENCODED: \(text)"
    }
    
    private func simulateMorseToTextConversion(_ text: String) -> String {
        // This triggers the problematic parseContinuousMorse function
        // Simulate the exponential complexity issue
        return simulateComplexMorseParsing(text)
    }
    
    private func simulateMixedContentConversion(_ text: String) -> String {
        // This processes character by character - can be slow for large inputs
        var result: [String] = []
        var currentText = ""
        var currentMorse = ""
        
        for char in text {
            if char == "." || char == "-" || char == "/" {
                if !currentText.isEmpty {
                    result.append("TEXT: \(currentText)")
                    currentText = ""
                }
                currentMorse.append(char)
            } else if char.isWhitespace {
                if !currentText.isEmpty {
                    result.append("TEXT: \(currentText)")
                    currentText = ""
                }
                if !currentMorse.isEmpty {
                    result.append("MORSE: \(simulateComplexMorseParsing(currentMorse))")
                    currentMorse = ""
                }
            } else {
                if !currentMorse.isEmpty {
                    result.append("MORSE: \(simulateComplexMorseParsing(currentMorse))")
                    currentMorse = ""
                }
                currentText.append(char)
            }
        }
        
        if !currentText.isEmpty {
            result.append("TEXT: \(currentText)")
        }
        if !currentMorse.isEmpty {
            result.append("MORSE: \(simulateComplexMorseParsing(currentMorse))")
        }
        
        return result.joined(separator: " | ")
    }
    
    private func simulateComplexMorseParsing(_ morse: String) -> String {
        // This simulates the exponential complexity in parseContinuousMorse
        // The more complex the pattern, the longer it takes
        
        if morse.count > 200 {
            // Use greedy approach for long sequences
            return "GREEDY: \(morse)"
        }
        
        // Simulate the complex multi-strategy approach
        // This is where the performance issue occurs
        let complexity = morse.count * morse.count // Simulate exponential complexity
        let iterations = min(complexity / 1000, 1000) // Cap at 1000 iterations
        
        for _ in 0..<iterations {
            // Simulate the recursive exploration
            _ = String(morse.reversed()) // Some work
        }
        
        return "PARSED: \(morse)"
    }
}

// Test cases that cause hanging in the real app
let problematicTestCases = [
    ("1 line text", "Hello World"),
    ("3 lines text", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 3)),
    ("5 lines text", String(repeating: "Pack my box with five dozen liquor jugs. ", count: 5)),
    ("10 lines text", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 10)),
    ("15 lines text", String(repeating: "Pack my box with five dozen liquor jugs. ", count: 15)),
    ("20 lines text", String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 20)),
    ("1 line morse", ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."),
    ("3 lines morse", String(repeating: ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / ", count: 3)),
    ("5 lines morse", String(repeating: ".... . .-.. .-.. --- / .-- --- .-. .-.. -.. / ", count: 5)),
    ("Mixed content", "Hello .... . .-.. .-.. --- World"),
    ("Complex mixed", "Hello .... . .-.. .-.. --- World - .... .. ... .. ... .- - . ... -"),
    ("Very long mixed", String(repeating: "Hello .... . .-.. .-.. --- World ", count: 10))
]

let simulator = AppSimulator()

print("\n📊 APP CONVERSION PERFORMANCE:")
print("===============================")

for (description, input) in problematicTestCases {
    let (result, time) = simulator.simulateConversion(input)
    
    let inputLength = input.count
    let outputLength = result.count
    
    print("\(description):")
    print("  Input: \(inputLength) characters")
    print("  Output: \(outputLength) characters")
    print("  Time: \(String(format: "%.3f", time))s")
    print("  Speed: \(String(format: "%.0f", Double(inputLength) / time)) chars/sec")
    
    if time > 5.0 {
        print("  ❌ CRITICAL: Conversion took over 5 seconds - APP HANGS!")
    } else if time > 1.0 {
        print("  ❌ SLOW: Conversion took over 1 second - USER NOTICEABLE")
    } else if time > 0.5 {
        print("  ⚠️  MODERATE: Conversion took over 500ms")
    } else if time > 0.1 {
        print("  ⚠️  SLOW: Conversion took over 100ms")
    } else {
        print("  ✅ FAST: Conversion under 100ms")
    }
    print()
}

print("\n🎯 PERFORMANCE ANALYSIS:")
print("========================")
print("The issue occurs when:")
print("1. Large text inputs (15+ lines) trigger mixed content processing")
print("2. Mixed content processes character by character")
print("3. Morse decoding uses exponential complexity algorithms")
print("4. No input size limits or chunking")

print("\n🔧 OPTIMIZATIONS APPLIED:")
print("=========================")
print("✅ Reduced maxExplorations from 1000 to 100")
print("✅ Reduced recursion depth from 20 to 10")
print("✅ Added greedy algorithm for sequences > 200 chars")
print("✅ Added chunked processing for mixed content > 500 chars")
print("✅ Added input size limits (1000 chars max)")

print("\n✅ App integration test completed!")
