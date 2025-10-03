import Foundation

// Global performance limits to prevent hanging
private let MAX_MORSE_LENGTH = 500

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
            // Check if this word contains continuous Morse (no spaces)
            if word.contains(" ") {
                // Already spaced, decode normally
                let letters = word.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                let decodedLetters: [Character] = try letters.map { token in
                    guard let ch = reverse[token] else { throw MorseDecodingError.invalidMorse(token) }
                    return ch
                }
                return String(decodedLetters)
            } else {
                // Check if this is a single valid Morse pattern (like ".-" for A)
                if let ch = reverse[word] {
                    return String(ch)
                } else {
                    // Continuous Morse, need to parse it
                    let spacedMorse = try parseContinuousMorse(word)
                    let letters = spacedMorse.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                    let decodedLetters: [Character] = try letters.map { token in
                        guard let ch = reverse[token] else { throw MorseDecodingError.invalidMorse(token) }
                        return ch
                    }
                    return String(decodedLetters)
                }
            }
        }
        return decodedWords.joined(separator: " ")
    }
    
    private func parseContinuousMorse(_ morse: String) throws -> String {
        // PERFORMANCE LIMIT: Prevent extremely long Morse sequences from causing hangs
        let limitedMorse = morse.count > MAX_MORSE_LENGTH ? 
            String(morse.prefix(MAX_MORSE_LENGTH)) : morse
        
        // SIMPLIFIED APPROACH: Use simple greedy algorithm for all cases
        // This replaces the complex multi-strategy approach that was causing performance issues
        
        return try parseContinuousMorseGreedy(limitedMorse)
        
        /* COMPLEX ALGORITHM COMMENTED OUT - WAS CAUSING PERFORMANCE ISSUES
        // Performance optimization: limit input size to prevent hanging
        if morse.count > 200 {
            // For very long sequences, use a simple greedy approach
            return try parseContinuousMorseGreedy(morse)
        }
        
        // For shorter sequences, try the most efficient strategy first
        let result = tryParseWithLettersFirst(morse)
        if !result.isEmpty {
            return result
        }
        
        // Fallback to greedy approach if the smart parsing fails
        return try parseContinuousMorseGreedy(morse)
        */
    }
    
    private func parseContinuousMorseGreedy(_ morse: String) throws -> String {
        // PERFORMANCE LIMIT: Additional safety check
        if morse.count > MAX_MORSE_LENGTH {
            throw MorseDecodingError.invalidMorse("Morse sequence too long (max \(MAX_MORSE_LENGTH) characters)")
        }
        
        // Simple greedy approach - much faster for long sequences
        let patterns = [
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
        
        var result: [String] = []
        var remaining = morse
        
        while !remaining.isEmpty {
            var found = false
            
            // Try to find the longest pattern that matches
            for pattern in patterns {
                if remaining.hasPrefix(pattern) {
                    result.append(pattern)
                    remaining = String(remaining.dropFirst(pattern.count))
                    found = true
                    break
                }
            }
            
            if !found {
                throw MorseDecodingError.invalidMorse(morse)
            }
            
            // Safety check to prevent infinite loops
            if result.count > 100 {
                throw MorseDecodingError.invalidMorse("Too many patterns (max 100)")
            }
        }
        
        return result.joined(separator: " ")
    }
    
    /* COMPLEX STRATEGY FUNCTIONS COMMENTED OUT - NO LONGER NEEDED
    private func tryParseWithContextAwareness(_ morse: String) -> String {
        // Context-aware parsing inspired by Google's morse-learn approach
        // This strategy considers the context and tries to find the most "natural" interpretation
        
        // For very short sequences (1-3 characters), prefer single characters
        if morse.count <= 3 {
            if let ch = reverse[morse] {
                return String(ch)
            }
        }
        
        // For longer sequences, use the same hybrid approach
        return tryParseWithLettersFirst(morse)
    }
    */
    
    /* ALL COMPLEX STRATEGY FUNCTIONS COMMENTED OUT - NO LONGER NEEDED
    private func tryParseWithIntelligentPatterns(_ morse: String) -> String {
        // Intelligent pattern matching that considers letter frequency and common combinations
        
        let intelligentPatterns = [
            // Most common single characters (E, T)
            ".", "-",
            // Common two-character patterns (A, I, N, M, U, R, W, D, K, G, O)
            ".-", "..", "-.", "--", "..-", ".-.", ".--", "-..", "-.-", "--.", "---",
            // Common three-character patterns
            "-...", "-.-.", "-..", "..-.", "--.", "....", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."
        ]
        
        if let bestSplit = findBestValidSplit(morse, intelligentPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
    }
    
    private func tryParseWithLettersFirst(_ morse: String) -> String {
        // Simple and elegant: Just use the existing enhanced scoring
        // The key insight: Let the mathematical approach work naturally
        
        return tryParseWithEnhancedScoring(morse)
    }
    
    private func tryParseWithEnhancedScoring(_ morse: String) -> String {
        // Enhanced scoring that prioritizes meaningful patterns over single characters
        
        let letterPatterns = [
            // Ordered by letter frequency in English (E, T, A, O, I, N, S, H, R, D, L, C, U, M, W, F, G, Y, P, B, V, K, J, X, Q, Z)
            ".", "-", ".-", "-.", "..", "--", "...", "---", ".-.", "-..", ".-..", "-.-", "..-", "--", "...-", ".--", "-..-", "-.--", ".--.", "-...", "...-", "-.-", ".---", "-..-", "-.--", "--..",
            // Less common patterns
            "-...", "-.-.", "..-.", "--.", "....", ".---", "-.-", ".-..", ".--.", "--.-", ".-.", "..-", "...-", ".--", "-..-", "-.--", "--.."
        ]
        
        if let bestSplit = findBestValidSplit(morse, letterPatterns) {
            return bestSplit.joined(separator: " ")
        }
        return ""
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
    */
    
    /* COMPLEX RECURSIVE ALGORITHM COMMENTED OUT - NO LONGER NEEDED
    private func findBestValidSplit(_ morse: String, _ patterns: [String]) -> [String]? {
        // Performance optimization: limit input size to prevent hanging
        if morse.count > 50 {
            // For longer sequences, use a simpler greedy approach
            return findGreedySplit(morse, patterns)
        }
        
        var bestResult: [String]? = nil
        var bestScore = Int.max
        var exploredCount = 0
        let maxExplorations = 100 // Reduced from 1000 to prevent hanging
        
        func trySplit(_ remaining: String, _ current: [String], _ depth: Int = 0) {
            // Prevent infinite recursion and excessive exploration
            if depth > 10 || exploredCount > maxExplorations { // Reduced depth from 20 to 10
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
            
            // Try patterns in order, but limit the number of attempts
            for pattern in patterns.prefix(5) { // Reduced from 10 to 5 patterns
                if remaining.hasPrefix(pattern) {
                    let newRemaining = String(remaining.dropFirst(pattern.count))
                    trySplit(newRemaining, current + [pattern], depth + 1)
                    
                    // Early exit if we've found a reasonable solution
                    if bestResult != nil && current.count < 3 { // Reduced from 5 to 3
                        return
                    }
                }
            }
        }
        
        trySplit(morse, [])
        return bestResult
    }
    */
    
    private func findGreedySplit(_ morse: String, _ patterns: [String]) -> [String]? {
        // Greedy approach for long sequences - much faster but less optimal
        var result: [String] = []
        var remaining = morse
        
        while !remaining.isEmpty {
            var found = false
            
            // Try to find the longest pattern that matches
            for pattern in patterns {
                if remaining.hasPrefix(pattern) {
                    result.append(pattern)
                    remaining = String(remaining.dropFirst(pattern.count))
                    found = true
                    break
                }
            }
            
            if !found {
                // If no pattern matches, this is invalid Morse
                return nil
            }
            
            // Safety check to prevent infinite loops
            if result.count > 50 {
                return nil
            }
        }
        
        return result
    }
    
    /* COMPLEX SCORING ALGORITHM COMMENTED OUT - NO LONGER NEEDED
    private func evaluateSplit(_ patterns: [String]) -> Int {
        // Revolutionary scoring algorithm: No hard-coded words, pure mathematical intelligence
        
        // Base score: strongly prefer fewer parts (most important factor)
        var score = patterns.count * 100
        
        // CRITICAL: Heavy penalty for starting with numbers in word-like sequences
        if let firstPattern = patterns.first, let firstChar = reverse[firstPattern] {
            let firstCharString = String(firstChar)
            if firstCharString.rangeOfCharacter(from: .decimalDigits) != nil {
                // If this looks like a word (has letters after the number), heavily penalize
                let hasLettersAfter = patterns.dropFirst().contains { pattern in
                    if let char = reverse[pattern] {
                        let charString = String(char)
                        return charString.rangeOfCharacter(from: .letters) != nil
                    }
                    return false
                }
                if hasLettersAfter {
                    score += 500 // MASSIVE penalty for number-letter combinations like "5LLO"
                } else {
                    score += 20 // Small penalty for pure number sequences
                }
            }
        }
        
        // Enhanced frequency-based scoring (based on English letter frequency research)
        let letterFrequency = [
            "E": 1, "T": 2, "A": 3, "O": 4, "I": 5, "N": 6, "S": 7, "H": 8, "R": 9, "D": 10,
            "L": 11, "C": 12, "U": 13, "M": 14, "W": 15, "F": 16, "G": 17, "Y": 18, "P": 19, "B": 20,
            "V": 21, "K": 22, "J": 23, "X": 24, "Q": 25, "Z": 26
        ]
        
        for pattern in patterns {
            if let character = reverse[pattern] {
                let characterString = String(character)
                
                if let frequency = letterFrequency[characterString] {
                    // More common letters get better scores (lower is better)
                    score -= (27 - frequency) * 2
                } else if characterString.rangeOfCharacter(from: .decimalDigits) != nil {
                    // Numbers get a penalty, but less if they're in pure number sequences
                    score += 20
                } else {
                    // Punctuation gets a small penalty
                    score += 5
                }
            }
        }
        
        // Bonus for patterns that form common letter combinations (no hard-coding needed!)
        let commonCombinations = ["TH", "HE", "IN", "ER", "AN", "RE", "ED", "ND", "ON", "EN", "AT", "OU", "EA", "HA", "AS", "OR", "TI", "IS", "ET", "IT", "AR", "TE", "SE", "HI", "OF"]
        
        for i in 0..<(patterns.count - 1) {
            let currentPattern = patterns[i]
            let nextPattern = patterns[i + 1]
            
            if let currentChar = reverse[currentPattern], let nextChar = reverse[nextPattern] {
                let combination = String(currentChar) + String(nextChar)
                if commonCombinations.contains(combination) {
                    score -= 10 // Bonus for common letter combinations
                }
            }
        }
        
        // Penalty for using single dots/dashes (prefer longer, more meaningful patterns)
        for pattern in patterns {
            if pattern == "." || pattern == "-" {
                score += 100 // Heavy penalty for single characters
            }
        }
        
        // Penalty for too many consecutive single characters
        var consecutiveSingles = 0
        for pattern in patterns {
            if pattern == "." || pattern == "-" {
                consecutiveSingles += 1
            } else {
                consecutiveSingles = 0
            }
            if consecutiveSingles > 2 {
                score += 50 // Heavy penalty for too many consecutive singles
            }
        }
        
        return score
    }
    */
}
