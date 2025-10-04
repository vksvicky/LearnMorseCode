import XCTest
@testable import MorseCore

final class AudioServiceVisualFeedbackTests: XCTestCase {
    
    private var audioService: AudioService!
    
    override func setUp() {
        super.setUp()
        audioService = AudioService()
    }
    
    override func tearDown() {
        audioService = nil
        super.tearDown()
    }
    
    // MARK: - Visual Feedback State Tests
    
    func testVisualFeedbackInitialState() {
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "No character should be highlighted initially")
        XCTAssertFalse(audioService.isElementPlaying, "No element should be playing initially")
    }
    
    func testVisualFeedbackStart() {
        let morseCode = ".... . .-.. .-.. ---"
        
        audioService.playMorseCode(morseCode)
        
        // Visual feedback should start when playing begins
        XCTAssertTrue(audioService.isPlaying, "Should be playing")
        // Note: currentCharacterIndex will change during playback, but we can't easily test timing
    }
    
    func testVisualFeedbackStop() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Stop
        audioService.stop()
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "Visual feedback should be reset when stopped")
        XCTAssertFalse(audioService.isElementPlaying, "No element should be playing when stopped")
    }
    
    func testVisualFeedbackPause() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Pause
        audioService.pause()
        XCTAssertFalse(audioService.isElementPlaying, "Element should not be playing when paused")
        XCTAssertTrue(audioService.isPaused, "Should be paused")
    }
    
    func testVisualFeedbackResume() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing and pause
        audioService.playMorseCode(morseCode)
        audioService.pause()
        XCTAssertTrue(audioService.isPaused)
        
        // Resume
        audioService.resume()
        XCTAssertTrue(audioService.isPlaying, "Should be playing when resumed")
        XCTAssertFalse(audioService.isPaused, "Should not be paused when resumed")
    }
    
    // MARK: - Timing Tests
    
    func testVisualFeedbackTimingGeneration() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // This test verifies that timing events are generated
        // The actual timing is complex to test without mocking timers
        audioService.playMorseCode(morseCode)
        
        XCTAssertTrue(audioService.isPlaying, "Should be playing to generate timing events")
    }
    
    func testVisualFeedbackMultiplePlayback() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // First playback
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Stop
        audioService.stop()
        XCTAssertEqual(audioService.currentCharacterIndex, -1)
        
        // Second playback
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "Should start from beginning")
    }
    
    // MARK: - Edge Cases
    
    func testVisualFeedbackEmptyMorseCode() {
        let emptyMorseCode = ""
        
        audioService.playMorseCode(emptyMorseCode)
        
        // Should handle empty Morse code gracefully
        XCTAssertFalse(audioService.isPlaying, "Should not be playing empty Morse code")
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "No character should be highlighted for empty Morse code")
    }
    
    func testVisualFeedbackSingleCharacter() {
        let singleCharMorse = "."
        
        audioService.playMorseCode(singleCharMorse)
        
        XCTAssertTrue(audioService.isPlaying, "Should be playing single character")
    }
    
    func testVisualFeedbackOnlySpaces() {
        let spacesOnly = "   "
        
        audioService.playMorseCode(spacesOnly)
        
        // Should handle spaces-only Morse code
        XCTAssertTrue(audioService.isPlaying, "Should be playing spaces-only Morse code")
    }
    
    // MARK: - State Consistency Tests
    
    func testStateConsistencyAfterStop() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        
        // Stop
        audioService.stop()
        
        // All states should be reset
        XCTAssertFalse(audioService.isPlaying, "Should not be playing after stop")
        XCTAssertFalse(audioService.isPaused, "Should not be paused after stop")
        XCTAssertEqual(audioService.currentCharacterIndex, -1, "No character should be highlighted after stop")
        XCTAssertFalse(audioService.isElementPlaying, "No element should be playing after stop")
    }
    
    func testStateConsistencyAfterPause() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        
        // Pause
        audioService.pause()
        
        // States should be consistent
        XCTAssertFalse(audioService.isPlaying, "Should not be playing when paused")
        XCTAssertTrue(audioService.isPaused, "Should be paused")
        XCTAssertFalse(audioService.isElementPlaying, "No element should be playing when paused")
    }
    
    func testStateConsistencyAfterResume() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing and pause
        audioService.playMorseCode(morseCode)
        audioService.pause()
        XCTAssertTrue(audioService.isPaused)
        
        // Resume
        audioService.resume()
        
        // States should be consistent
        XCTAssertTrue(audioService.isPlaying, "Should be playing when resumed")
        XCTAssertFalse(audioService.isPaused, "Should not be paused when resumed")
    }
    
    // MARK: - Performance Tests
    
    func testVisualFeedbackPerformance() {
        let longMorseCode = String(repeating: ".... . .-.. .-.. --- ", count: 50)
        
        measure {
            audioService.playMorseCode(longMorseCode)
            audioService.stop()
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testVisualFeedbackInvalidMorseCode() {
        let invalidMorseCode = ".... . .-.. .-.. --- ."
        
        // Should handle invalid Morse code gracefully
        audioService.playMorseCode(invalidMorseCode)
        
        // The audio service should still attempt to play, even if the Morse code is invalid
        XCTAssertTrue(audioService.isPlaying, "Should attempt to play even invalid Morse code")
    }
    
    // MARK: - Integration Tests
    
    func testVisualFeedbackWithAudioPlayback() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Start playing
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Pause during playback
        audioService.pause()
        XCTAssertTrue(audioService.isPaused)
        XCTAssertFalse(audioService.isElementPlaying)
        
        // Resume
        audioService.resume()
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        
        // Stop
        audioService.stop()
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        XCTAssertEqual(audioService.currentCharacterIndex, -1)
        XCTAssertFalse(audioService.isElementPlaying)
    }
    
    func testVisualFeedbackMultipleOperations() {
        let morseCode = ".... . .-.. .-.. ---"
        
        // Play
        audioService.playMorseCode(morseCode)
        XCTAssertTrue(audioService.isPlaying)
        
        // Pause
        audioService.pause()
        XCTAssertTrue(audioService.isPaused)
        
        // Resume
        audioService.resume()
        XCTAssertTrue(audioService.isPlaying)
        
        // Pause again
        audioService.pause()
        XCTAssertTrue(audioService.isPaused)
        
        // Stop
        audioService.stop()
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
    }
}
