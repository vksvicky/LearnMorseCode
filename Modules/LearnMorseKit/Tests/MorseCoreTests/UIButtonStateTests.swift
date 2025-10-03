import XCTest
@testable import MorseCore

@MainActor
final class UIButtonStateTests: XCTestCase {
    
    // MARK: - Button State Logic Tests
    
    func testPlayButtonStateLogic() {
        // Test the logic that determines button text and appearance
        
        // Initial state (stopped)
        var isPlaying = false
        var isPaused = false
        var outputText = ".... . .-.. .-.. ---"
        
        let playButtonText = isPaused ? "Resume" : (isPlaying ? "Pause" : "Play")
        let playButtonIcon = isPaused ? "play.fill" : (isPlaying ? "pause.fill" : "play.fill")
        let playButtonColor = isPaused ? "orange" : (isPlaying ? "red" : "green")
        let playButtonEnabled = !outputText.isEmpty
        
        XCTAssertEqual(playButtonText, "Play", "Should show 'Play' when stopped")
        XCTAssertEqual(playButtonIcon, "play.fill", "Should show play icon when stopped")
        XCTAssertEqual(playButtonColor, "green", "Should be green when stopped")
        XCTAssertTrue(playButtonEnabled, "Should be enabled when there's output text")
        
        // Playing state
        isPlaying = true
        isPaused = false
        
        let playButtonTextPlaying = isPaused ? "Resume" : (isPlaying ? "Pause" : "Play")
        let playButtonIconPlaying = isPaused ? "play.fill" : (isPlaying ? "pause.fill" : "play.fill")
        let playButtonColorPlaying = isPaused ? "orange" : (isPlaying ? "red" : "green")
        
        XCTAssertEqual(playButtonTextPlaying, "Pause", "Should show 'Pause' when playing")
        XCTAssertEqual(playButtonIconPlaying, "pause.fill", "Should show pause icon when playing")
        XCTAssertEqual(playButtonColorPlaying, "red", "Should be red when playing")
        
        // Paused state
        isPlaying = false
        isPaused = true
        
        let playButtonTextPaused = isPaused ? "Resume" : (isPlaying ? "Pause" : "Play")
        let playButtonIconPaused = isPaused ? "play.fill" : (isPlaying ? "pause.fill" : "play.fill")
        let playButtonColorPaused = isPaused ? "orange" : (isPlaying ? "red" : "green")
        
        XCTAssertEqual(playButtonTextPaused, "Resume", "Should show 'Resume' when paused")
        XCTAssertEqual(playButtonIconPaused, "play.fill", "Should show play icon when paused")
        XCTAssertEqual(playButtonColorPaused, "orange", "Should be orange when paused")
    }
    
    func testStopButtonStateLogic() {
        // Test the logic that determines stop button state
        
        // Initial state (stopped)
        var isPlaying = false
        var isPaused = false
        
        let stopButtonEnabled = isPlaying || isPaused
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when stopped")
        
        // Playing state
        isPlaying = true
        isPaused = false
        
        let stopButtonEnabledPlaying = isPlaying || isPaused
        XCTAssertTrue(stopButtonEnabledPlaying, "Stop button should be enabled when playing")
        
        // Paused state
        isPlaying = false
        isPaused = true
        
        let stopButtonEnabledPaused = isPlaying || isPaused
        XCTAssertTrue(stopButtonEnabledPaused, "Stop button should be enabled when paused")
    }
    
    func testButtonStateTransitions() {
        // Test the complete state transition logic
        
        var isPlaying = false
        var isPaused = false
        let outputText = ".... . .-.. .-.. ---"
        
        // Initial state
        XCTAssertFalse(isPlaying)
        XCTAssertFalse(isPaused)
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Play")
        XCTAssertFalse(getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused))
        
        // Play action
        if !isPlaying && !isPaused {
            isPlaying = true
            isPaused = false
        }
        XCTAssertTrue(isPlaying)
        XCTAssertFalse(isPaused)
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Pause")
        XCTAssertTrue(getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused))
        
        // Pause action
        if isPlaying {
            isPlaying = false
            isPaused = true
        }
        XCTAssertFalse(isPlaying)
        XCTAssertTrue(isPaused)
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Resume")
        XCTAssertTrue(getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused))
        
        // Resume action
        if isPaused {
            isPlaying = true
            isPaused = false
        }
        XCTAssertTrue(isPlaying)
        XCTAssertFalse(isPaused)
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Pause")
        XCTAssertTrue(getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused))
        
        // Stop action
        isPlaying = false
        isPaused = false
        XCTAssertFalse(isPlaying)
        XCTAssertFalse(isPaused)
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Play")
        XCTAssertFalse(getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused))
    }
    
    func testButtonStateWithEmptyOutput() {
        // Test button states when there's no output text
        
        let isPlaying = false
        let isPaused = false
        let outputText = ""
        
        let playButtonEnabled = !outputText.isEmpty
        XCTAssertFalse(playButtonEnabled, "Play button should be disabled when output is empty")
        
        let stopButtonEnabled = isPlaying || isPaused
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when not playing or paused")
    }
    
    func testButtonStateConsistency() {
        // Test that button states are always consistent
        
        let states: [(Bool, Bool)] = [
            (false, false), // stopped
            (true, false),  // playing
            (false, true)   // paused
        ]
        
        for (isPlaying, isPaused) in states {
            // Test that isPlaying and isPaused are mutually exclusive
            if isPlaying && isPaused {
                XCTFail("isPlaying and isPaused should not both be true")
            }
            
            // Test button text consistency
            let buttonText = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
            let expectedText = isPaused ? "Resume" : (isPlaying ? "Pause" : "Play")
            XCTAssertEqual(buttonText, expectedText, "Button text should be consistent with state")
            
            // Test stop button consistency
            let stopEnabled = getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused)
            let expectedStopEnabled = isPlaying || isPaused
            XCTAssertEqual(stopEnabled, expectedStopEnabled, "Stop button state should be consistent")
        }
    }
    
    // MARK: - Helper Functions
    
    private func getButtonText(isPlaying: Bool, isPaused: Bool) -> String {
        return isPaused ? "Resume" : (isPlaying ? "Pause" : "Play")
    }
    
    private func getStopButtonEnabled(isPlaying: Bool, isPaused: Bool) -> Bool {
        return isPlaying || isPaused
    }
    
    // MARK: - Edge Cases
    
    func testButtonStateEdgeCases() {
        // Test edge cases that shouldn't happen but we should handle gracefully
        
        // Both true (shouldn't happen but test for robustness)
        var isPlaying = true
        var isPaused = true
        
        let buttonText = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
        XCTAssertEqual(buttonText, "Resume", "Should prioritize paused state when both are true")
        
        let stopEnabled = getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused)
        XCTAssertTrue(stopEnabled, "Stop should be enabled when either is true")
    }
    
    func testButtonStateWithLongOutput() {
        // Test button states with very long output text
        
        let longOutput = String(repeating: ".... . .-.. .-.. --- ", count: 100)
        let isPlaying = false
        let isPaused = false
        
        let playButtonEnabled = !longOutput.isEmpty
        XCTAssertTrue(playButtonEnabled, "Play button should be enabled with long output")
        
        let stopButtonEnabled = isPlaying || isPaused
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when not playing or paused")
    }
    
    // MARK: - Performance Tests
    
    func testButtonStatePerformance() {
        // Test that button state calculations are fast
        
        measure {
            for _ in 0..<1000 {
                let isPlaying = Bool.random()
                let isPaused = Bool.random()
                
                _ = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
                _ = getStopButtonEnabled(isPlaying: isPlaying, isPaused: isPaused)
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testButtonStateWithAudioService() {
        // Test button state logic with actual AudioService
        
        let audioService = AudioService()
        
        // Initial state
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        XCTAssertEqual(getButtonText(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused), "Play")
        XCTAssertFalse(getStopButtonEnabled(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused))
        
        // Play
        audioService.playMorseCode(".... . .-.. .-.. ---")
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        XCTAssertEqual(getButtonText(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused), "Pause")
        XCTAssertTrue(getStopButtonEnabled(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused))
        
        // Pause
        audioService.pause()
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertTrue(audioService.isPaused)
        XCTAssertEqual(getButtonText(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused), "Resume")
        XCTAssertTrue(getStopButtonEnabled(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused))
        
        // Resume
        audioService.resume()
        XCTAssertTrue(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        XCTAssertEqual(getButtonText(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused), "Pause")
        XCTAssertTrue(getStopButtonEnabled(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused))
        
        // Stop
        audioService.stop()
        XCTAssertFalse(audioService.isPlaying)
        XCTAssertFalse(audioService.isPaused)
        XCTAssertEqual(getButtonText(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused), "Play")
        XCTAssertFalse(getStopButtonEnabled(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused))
    }
}
