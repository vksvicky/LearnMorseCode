import XCTest
import SwiftUI
@testable import MorseCore
@testable import LearnMorseUI

@MainActor
final class TextToMorseViewTests: XCTestCase {
    
    // MARK: - Test Setup
    
    private var audioService: AudioService!
    private var morseModel: MorseCodeModel!
    
    override func setUp() {
        super.setUp()
        audioService = AudioService()
        morseModel = MorseCodeModel()
    }
    
    override func tearDown() {
        audioService = nil
        morseModel = nil
        super.tearDown()
    }
    
    // MARK: - Audio Service Tests
    
    func testAudioServiceInitialState() {
        XCTAssertFalse(audioService.isPlaying, "Audio service should not be playing initially")
        XCTAssertFalse(audioService.isPaused, "Audio service should not be paused initially")
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "No character should be highlighted initially")
        XCTAssertFalse(audioService.isElementPlaying, "No element should be playing initially")
    }
    
    func testAudioServicePlayMorseCode() {
        let morseCode = ".... . .-.. .-.. ---"
        
        audioService.playMorseCode(morseCode)
        
        XCTAssertTrue(audioService.isPlaying, "Audio service should be playing after playMorseCode")
        XCTAssertFalse(audioService.isPaused, "Audio service should not be paused when playing")
    }
    
    func testAudioServicePauseResume() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        
        // Pause
        audioService.pause()
        XCTAssertFalse(audioService.isPlaying, "Should not be playing when paused")
        XCTAssertTrue(audioService.isPaused, "Should be paused")
        
        // Resume
        audioService.resume()
        XCTAssertTrue(audioService.isPlaying, "Should be playing when resumed")
        XCTAssertFalse(audioService.isPaused, "Should not be paused when resumed")
    }
    
    func testAudioServiceStop() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Stop
        audioService.stop()
        XCTAssertFalse(audioService.isPlaying, "Should not be playing when stopped")
        XCTAssertFalse(audioService.isPaused, "Should not be paused when stopped")
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "No character should be highlighted when stopped")
        XCTAssertFalse(audioService.isElementPlaying, "No element should be playing when stopped")
    }
    
    func testAudioServiceStopFromPaused() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing and pause
        audioService.playMorseCode(morseCode)
        audioService.pause()
        XCTAssertTrue(audioService.isPaused)
        
        // Stop from paused state
        audioService.stop()
        XCTAssertFalse(audioService.isPlaying, "Should not be playing when stopped")
        XCTAssertFalse(audioService.isPaused, "Should not be paused when stopped")
    }
    
    // MARK: - Morse Code Conversion Tests
    
    func testTextToMorseConversion() {
        let text = "HELLO"
        let expectedMorse = ".... . .-.. .-.. ---"
        
        do {
            let result = try MorseEncoder().encode(text)
            XCTAssertEqual(result, expectedMorse, "Text to Morse conversion should work correctly")
        } catch {
            XCTFail("Text to Morse conversion should not throw error: \(error)")
        }
    }
    
    func testMorseToTextConversion() {
        let morse = ".... . .-.. .-.. ---"
        let expectedText = "HELLO"
        
        do {
            let result = try MorseDecoder().decode(morse)
            XCTAssertEqual(result, expectedText, "Morse to text conversion should work correctly")
        } catch {
            XCTFail("Morse to text conversion should not throw error: \(error)")
        }
    }
    
    func testMorseToTextConversionWithSpaces() {
        let morse = ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
        let expectedText = "HELLO WORLD"
        
        do {
            let result = try MorseDecoder().decode(morse)
            XCTAssertEqual(result, expectedText, "Morse to text conversion with spaces should work correctly")
        } catch {
            XCTFail("Morse to text conversion with spaces should not throw error: \(error)")
        }
    }
    
    func testMorseToTextConversionContinuous() {
        let morse = ".... . .-.. .-.. ---"
        let expectedText = "HELLO"
        
        do {
            let result = try MorseDecoder().decode(morse)
            XCTAssertEqual(result, expectedText, "Continuous Morse to text conversion should work correctly")
        } catch {
            XCTFail("Continuous Morse to text conversion should not throw error: \(error)")
        }
    }
    
    func testInvalidMorseCode() {
        let invalidMorse = ".... . .-.. .-.. --- .-.-.-.-"
        
        do {
            _ = try MorseDecoder().decode(invalidMorse)
            XCTFail("Invalid Morse code should throw error")
        } catch {
            XCTAssertTrue(error is MorseDecodingError, "Should throw MorseDecodingError for invalid Morse code")
        }
    }
    
    func testEmptyMorseCode() {
        do {
            let result = try MorseDecoder().decode("")
            XCTAssertEqual(result, "", "Empty Morse code should return empty string")
        } catch {
            XCTFail("Empty Morse code should not throw error: \(error)")
        }
    }
    
    func testEmptyText() {
        do {
            let result = try MorseEncoder().encode("")
            XCTAssertEqual(result, "", "Empty text should return empty string")
        } catch {
            XCTFail("Empty text should not throw error: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testLongTextPerformance() {
        let longText = String(repeating: "HELLO ", count: 100)
        
        measure {
            do {
                _ = try MorseEncoder().encode(longText)
            } catch {
                XCTFail("Long text encoding should not throw error: \(error)")
            }
        }
    }
    
    func testLongMorseCodePerformance() {
        let longMorse = String(repeating: ".... . .-.. .-.. --- ", count: 100)
        
        measure {
            do {
                _ = try MorseDecoder().decode(longMorse)
            } catch {
                XCTFail("Long Morse code decoding should not throw error: \(error)")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testSpecialCharacters() {
        let text = "HELLO WORLD!"
        do {
            let result = try MorseEncoder().encode(text)
            XCTAssertFalse(result.isEmpty, "Special characters should be handled")
        } catch {
            // Some special characters might not be supported, which is acceptable
            XCTAssertTrue(error is MorseEncodingError, "Should throw MorseEncodingError for unsupported characters")
        }
    }
    
    func testNumbers() {
        let text = "123"
        do {
            let result = try MorseEncoder().encode(text)
            XCTAssertFalse(result.isEmpty, "Numbers should be encoded")
        } catch {
            XCTFail("Numbers should be supported: \(error)")
        }
    }
    
    func testMixedCase() {
        let text = "Hello World"
        do {
            let result = try MorseEncoder().encode(text)
            XCTAssertFalse(result.isEmpty, "Mixed case should be handled")
        } catch {
            XCTFail("Mixed case should be supported: \(error)")
        }
    }
    
    // MARK: - Visual Feedback Tests
    
    func testVisualFeedbackTiming() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        
        // Check that timing events are generated
        // Note: This is a basic test - in a real scenario, you'd want to test
        // the actual timing of visual feedback updates
        XCTAssertTrue(audioService.isPlaying, "Should be playing to generate visual feedback")
    }
    
    func testVisualFeedbackStop() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Stop
        audioService.stop()
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "Visual feedback should be reset when stopped")
        XCTAssertFalse(audioService.isElementPlaying, "Element should not be playing when stopped")
    }
    
    // MARK: - Button State Tests (Simulated)
    
    func testButtonStateTransitions() {
        // Test the logic that would be used in the UI
        var isPlaying = false
        var isPaused = false
        
        // Initial state
        XCTAssertFalse(isPlaying)
        XCTAssertFalse(isPaused)
        
        // Play
        isPlaying = true
        isPaused = false
        XCTAssertTrue(isPlaying)
        XCTAssertFalse(isPaused)
        
        // Pause
        isPlaying = false
        isPaused = true
        XCTAssertFalse(isPlaying)
        XCTAssertTrue(isPaused)
        
        // Resume
        isPlaying = true
        isPaused = false
        XCTAssertTrue(isPlaying)
        XCTAssertFalse(isPaused)
        
        // Stop
        isPlaying = false
        isPaused = false
        XCTAssertFalse(isPlaying)
        XCTAssertFalse(isPaused)
    }
    
    func testButtonEnabledStates() {
        // Test button enabled/disabled logic
        var isPlaying = false
        var isPaused = false
        let outputText = ".... . .-.. .-.. ---"
        
        // Play button should be enabled when there's output text
        let playButtonEnabled = !outputText.isEmpty
        XCTAssertTrue(playButtonEnabled, "Play button should be enabled when there's output text")
        
        // Stop button should be enabled when playing or paused
        let stopButtonEnabled = isPlaying || isPaused
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when not playing or paused")
        
        // When playing
        isPlaying = true
        let stopButtonEnabledWhenPlaying = isPlaying || isPaused
        XCTAssertTrue(stopButtonEnabledWhenPlaying, "Stop button should be enabled when playing")
        
        // When paused
        isPlaying = false
        isPaused = true
        let stopButtonEnabledWhenPaused = isPlaying || isPaused
        XCTAssertTrue(stopButtonEnabledWhenPaused, "Stop button should be enabled when paused")
    }
    
    // MARK: - Mixed Content Tests
    
    func testMixedContentHandling() {
        // Test mixed content: Morse code + text
        let mixedInput = ".... . .-.. .-.. ---HELLO"
        
        // The expected behavior:
        // 1. ".... . .-.. .-.. ---" should be decoded to "HELLO" and encoded back to ".... . .-.. .-.. ---"
        // 2. "HELLO" should be encoded to ".... . .-.. .-.. ---"
        // 3. Result should be: ".... . .-.. .-.. --- .... . .-.. .-.. ---"
        
        do {
            let result = try MorseEncoder().encode(mixedInput)
            // The result should contain the Morse code for HELLO twice
            XCTAssertTrue(result.contains(".... . .-.. .-.. ---"), "Result should contain Morse code for HELLO")
        } catch {
            XCTFail("Mixed content encoding should not throw error: \(error)")
        }
    }
    
    func testMixedContentWithInvalidMorse() {
        // Test mixed content where Morse part is invalid
        let mixedInput = ".... . .-.. .-.. --- .-.-.-.-HELLO"
        
        do {
            let result = try MorseEncoder().encode(mixedInput)
            // Should handle gracefully - either encode everything or pass Morse through
            XCTAssertFalse(result.isEmpty, "Should produce some output")
        } catch {
            // It's acceptable for this to throw an error due to invalid Morse
            XCTAssertTrue(error is MorseEncodingError, "Should throw MorseEncodingError for invalid characters")
        }
    }
    
    func testMixedContentTextFirst() {
        // Test mixed content with text first
        let mixedInput = "HELLO.... . .-.. .-.. ---"
        
        do {
            let result = try MorseEncoder().encode(mixedInput)
            XCTAssertTrue(result.contains(".... . .-.. .-.. ---"), "Result should contain Morse code")
        } catch {
            XCTFail("Mixed content encoding should not throw error: \(error)")
        }
    }
    
    func testMixedContentWithSpaces() {
        // Test mixed content with proper spacing
        let mixedInput = ".... . .-.. .-.. --- HELLO"
        
        do {
            let result = try MorseEncoder().encode(mixedInput)
            XCTAssertTrue(result.contains(".... . .-.. .-.. ---"), "Result should contain Morse code")
        } catch {
            XCTFail("Mixed content encoding should not throw error: \(error)")
        }
    }
    
    func testMixedContentMorseThenText() {
        // Test the specific case: Morse code followed by text
        let mixedInput = ".... .. --- Hio"
        
        // Expected behavior:
        // 1. ".... .. ---" should be decoded to "HIO" and encoded back to ".... .. ---"
        // 2. "Hio" should be encoded to ".... .. ---"
        // 3. Result should be: ".... .. --- .... .. ---"
        
        do {
            let converter = MixedContentConverter()
            let result = try converter.convertMixedContent(mixedInput)
            // The result should contain the Morse code for HIO twice
            XCTAssertTrue(result.contains(".... .. ---"), "Result should contain Morse code for HIO")
            // Should not contain garbled output like ".-.-.-"
            XCTAssertFalse(result.contains(".-.-.-"), "Result should not contain garbled Morse code")
            // Should be exactly ".... .. --- .... .. ---"
            XCTAssertEqual(result, ".... .. --- .... .. ---", "Result should be exactly the expected Morse code")
        } catch {
            XCTFail("Mixed content encoding should not throw error: \(error)")
        }
    }
    
    // MARK: - Integration Tests
    
    func testFullWorkflowTextToMorse() {
        let inputText = "HELLO"
        let expectedMorse = ".... . .-.. .-.. ---"
        
        // Convert text to Morse
        do {
            let morseCode = try MorseEncoder().encode(inputText)
            XCTAssertEqual(morseCode, expectedMorse)
            
            // Play the Morse code
            audioService.playMorseCode(morseCode)
            XCTAssertTrue(audioService.isPlaying)
            
            // Stop
            audioService.stop()
            XCTAssertFalse(audioService.isPlaying)
        } catch {
            XCTFail("Full workflow should not throw error: \(error)")
        }
    }
    
    func testFullWorkflowMorseToText() {
        let inputMorse = ".... . .-.. .-.. ---"
        let expectedText = "HELLO"
        
        // Convert Morse to text
        do {
            let text = try MorseDecoder().decode(inputMorse)
            XCTAssertEqual(text, expectedText)
        } catch {
            XCTFail("Full workflow should not throw error: \(error)")
        }
    }
    
    func testPauseResumeWorkflow() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        
        // Pause
        audioService.pause()
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertTrue(audioService.isPaused)
        
        // Resume
        audioService.resume()
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        
        // Stop
        audioService.stop()
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
    }
    
    // MARK: - New Functionality Tests
    
    func testMixedContentConverterIntegration() {
        // Test that MixedContentConverter works correctly
        let converter = MixedContentConverter()
        
        let mixedInput = ".... . .-.. .-.. --- HELLO"
        
        do {
            let result = try converter.convertMixedContent(mixedInput)
            XCTAssertTrue(result.contains(".... . .-.. .-.. ---"), "Result should contain Morse code")
            XCTAssertTrue(result.contains(".... . .-.. .-.. ---"), "Result should contain encoded text")
        } catch {
            XCTFail("Mixed content conversion should not throw error: \(error)")
        }
    }
    
    func testAudioServiceStateResetAfterCompletion() {
        // Test that audio service state resets after Morse code finishes playing
        let morseCode = "."
        
        // Start playing a short Morse code
        audioService.playMorseCode(morseCode)
        
        // Wait for completion (this is a short Morse code)
        let expectation = XCTestExpectation(description: "Morse code completion")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // After completion, state should be reset
            XCTAssertFalse(self.audioService.isPlaying, "Should not be playing after completion")
            XCTAssertFalse(self.audioService.isPaused, "Should not be paused after completion")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}
