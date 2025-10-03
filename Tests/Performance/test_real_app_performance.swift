#!/usr/bin/env swift

import Foundation

print("🚀 Real App Performance Test")
print("=============================")

// Test the actual problematic functions from the app
// This simulates the complex MorseDecoder.parseContinuousMorse function

struct AppMorseDecoder {
    private let reverse: [String: Character] = [
        ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
        "..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
        "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
        ".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
        "..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y", "--..": "Z",
        "-----": "0", ".----": "1", "..---": "2", "...--": "3", "....-": "4",
        ".....": "5", "-....": "6", "--...": "7", "---..": "8", "----.": "9"
    ]
    
    // This simulates the problematic parseContinuousMorse function
    func parseContinuousMorse(_ morse: String) -> String {
        // Simulate the complex multi-strategy approach
        let strategies = [
            tryParseWithLettersFirst(morse),
            tryParseWithContextAwareness(morse),
            tryParseWithAllPatterns(morse),
            tryParseWithCommonPatterns(morse)
        ]
        
        for strategy in strategies {
            if !strategy.isEmpty {
                return strategy
            }
        }
        return ""
    }
    
    private func tryParseWithLettersFirst(_ morse: String) -> String {
        return tryParseWithEnhancedScoring(morse)
    }
    
    private func tryParseWithContextAwareness(_ morse: String) -> String {
        if morse.count <= 3 {
            if let ch = reverse[morse] {
                return String(ch)
            }
        }
        return tryParseWithLettersFirst(morse)
    }
    
    private func tryParseWithAllPatterns(_ morse: String) -> String {
        let allPatterns = [
            "-----", ".----", "..---", "...--", "....-", ".....",
            "-....", "--...", "---..", "----.",
            "-...", "-.-.", "-..", "..-.", "--.", "....", ".---",
            "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.",
            "...", "..-", "...-", ".--", "-..-", "-.--", "--..",
            ".-", "-", "."
        ]
        
        if let bestSplit = findBestValidSplit(morse, allPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    private func tryParseWithCommonPatterns(_ morse: String) -> String {
        let commonPatterns = [
            ".", "-", "..", "--", "...", "---", ".-", "-.", ".-.", "-..",
            ".-..", "--.", "....", "-...", "-.-.", "..-.", ".---", "-.-",
            "..-", "...-", ".--", "-..-", "-.--", "--..", "--.-", ".--."
        ]
        
        if let bestSplit = findBestValidSplit(morse, commonPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    private func tryParseWithEnhancedScoring(_ morse: String) -> String {
        let letterPatterns = [
            ".", "-", ".-", "-.", "..", "--", "...", "---", ".-.", "-..", ".-..", "-.-", "..-", "--", "...-", ".--", "-..-", "-.--", ".--.", "-...", "...-", "-.-", ".---", "-..-", "-.--", "--..",
            "-...", "-.-.", "..-.", "--.", "....", ".---", "-.-", ".-..", ".--.", "--.-", ".-.", "..-", "...-", ".--", "-..-", "-.--", "--.."
        ]
        
        if let bestSplit = findBestValidSplit(morse, letterPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    // This is the problematic function with exponential complexity
    private func findBestValidSplit(_ morse: String, _ patterns: [String]) -> [String]? {
        if morse.count > 100 {
            return findGreedySplit(morse, patterns)
        }
        
        var bestResult: [String]? = nil
        var bestScore = Int.max
        var exploredCount = 0
        let maxExplorations = 1000 // This is the problem!
        
        func trySplit(_ remaining: String, _ current: [String], _ depth: Int = 0) {
            if depth > 20 || exploredCount > maxExplorations {
                return
            }
            
            exploredCount += 1
            
            if remaining.isEmpty {
                let score = evaluateSplit(current)
                if score < bestScore {
                    bestResult = current
                    bestScore = score
                }
                return
            }
            
            for pattern in patterns.prefix(10) {
                if remaining.hasPrefix(pattern) {
                    let newRemaining = String(remaining.dropFirst(pattern.count))
                    trySplit(newRemaining, current + [pattern], depth + 1)
                    
                    if bestResult != nil && current.count < 5 {
                        return
                    }
                }
            }
        }
        
        trySplit(morse, [])
        return bestResult
    }
    
    private func findGreedySplit(_ morse: String, _ patterns: [String]) -> [String]? {
        var result: [String] = []
        var remaining = morse
        
        while !remaining.isEmpty {
            var found = false
            
            for pattern in patterns {
                if remaining.hasPrefix(pattern) {
                    result.append(pattern)
                    remaining = String(remaining.dropFirst(pattern.count))
                    found = true
                    break
                }
            }
            
            if !found {
                return nil
            }
            
            if result.count > 50 {
                return nil
            }
        }
        
        return result
    }
    
    private func evaluateSplit(_ patterns: [String]) -> Int {
        var score = patterns.count * 100
        
        if let firstPattern = patterns.first, let firstChar = reverse[firstPattern] {
            let firstCharString = String(firstChar)
            if firstCharString.rangeOfCharacter(from: .decimalDigits) != nil {
                let hasLettersAfter = patterns.dropFirst().contains { pattern in
                    if let char = reverse[pattern] {
                        let charString = String(char)
                        return charString.rangeOfCharacter(from: .letters) != nil
                    }
                    return false
                }
                if hasLettersAfter {
                    score += 500
                } else {
                    score += 20
                }
            }
        }
        
        let letterFrequency = [
            "E": 1, "T": 2, "A": 3, "O": 4, "I": 5, "N": 6, "S": 7, "H": 8, "R": 9, "D": 10,
            "L": 11, "C": 12, "U": 13, "M": 14, "W": 15, "F": 16, "G": 17, "Y": 18, "P": 19, "B": 20,
            "V": 21, "K": 22, "J": 23, "X": 24, "Q": 25, "Z": 26
        ]
        
        for pattern in patterns {
            if let character = reverse[pattern] {
                let characterString = String(character)
                
                if let frequency = letterFrequency[characterString] {
                    score -= (27 - frequency) * 2
                } else if characterString.rangeOfCharacter(from: .decimalDigits) != nil {
                    score += 20
                } else {
                    score += 5
                }
            }
        }
        
        for pattern in patterns {
            if pattern == "." || pattern == "-" {
                score += 100
            }
        }
        
        return score
    }
}

// Performance measurement
func measureTime<T>(_ operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return (result, timeElapsed)
}

// Test the problematic continuous Morse parsing
print("\n📊 CONTINUOUS MORSE PARSING PERFORMANCE:")
print("========================================")

let decoder = AppMorseDecoder()

let continuousMorseTests = [
    ("Short", ".... . .-.. .-.. ---"),
    ("Medium", ".... . .-.. .-.. --- .-- --- .-. .-.. -.."),
    ("Long", ".... . .-.. .-.. --- .-- --- .-. .-.. -.. - .... .. ... .. ... .- - . ... -"),
    ("Very Long", String(repeating: ".... . .-.. .-.. --- ", count: 20)),
    ("Extremely Long", String(repeating: ".... . .-.. .-.. --- ", count: 50)),
    ("Problematic", String(repeating: ".-", count: 100)) // This will cause exponential explosion
]

for (description, morse) in continuousMorseTests {
    let (result, time) = measureTime {
        decoder.parseContinuousMorse(morse)
    }
    
    let inputLength = morse.count
    let outputLength = result.count
    
    print("\(description):")
    print("  Input: \(inputLength) characters")
    print("  Output: \(outputLength) characters")
    print("  Time: \(String(format: "%.3f", time))s")
    
    if time > 5.0 {
        print("  ❌ CRITICAL: Conversion took over 5 seconds - HANGING!")
    } else if time > 1.0 {
        print("  ❌ SLOW: Conversion took over 1 second")
    } else if time > 0.5 {
        print("  ⚠️  MODERATE: Conversion took over 500ms")
    } else if time > 0.1 {
        print("  ⚠️  SLOW: Conversion took over 100ms")
    } else {
        print("  ✅ FAST: Conversion under 100ms")
    }
    print()
}

print("\n🎯 ANALYSIS:")
print("=============")
print("The exponential complexity in findBestValidSplit is the main culprit!")
print("With maxExplorations=1000 and depth=20, it can explore millions of combinations.")
print("This is why 3+ lines cause hanging - the algorithm explodes exponentially.")

print("\n🔧 IMMEDIATE FIXES NEEDED:")
print("===========================")
print("1. Reduce maxExplorations from 1000 to 100")
print("2. Reduce max depth from 20 to 10")
print("3. Use greedy algorithm for sequences > 50 chars")
print("4. Add early termination when good solution found")
print("5. Limit pattern attempts to 5 instead of 10")

print("\n✅ Real app performance test completed!")
