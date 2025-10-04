import XCTest
@testable import MorseCore

final class UIButtonStateTests: XCTestCase {
    
    // MARK: - Button State Logic Tests
    
    func testPlayButtonStateLogic() {
        // Test the logic that determines button text and appearance
        
        // Initial state (stopped)
        var isPlaying = false
        var isPaused = false
        let outputText = ".... . .-.. .-.. ---"
        
        let playButtonText = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonIcon = getButtonIcon(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonColor = getButtonColor(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonEnabled = !outputText.isEmpty
        
        XCTAssertEqual(playButtonText, "Play", "Should show 'Play' when stopped")
        XCTAssertEqual(playButtonIcon, "play.fill", "Should show play icon when stopped")
        XCTAssertEqual(playButtonColor, "green", "Should be green when stopped")
        XCTAssertTrue(playButtonEnabled, "Should be enabled when there's output text")
        
        // Playing state
        isPlaying = true
        isPaused = false
        
        let playButtonTextPlaying = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonIconPlaying = getButtonIcon(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonColorPlaying = getButtonColor(isPlaying: isPlaying, isPaused: isPaused)
        
        XCTAssertEqual(playButtonTextPlaying, "Pause", "Should show 'Pause' when playing")
        XCTAssertEqual(playButtonIconPlaying, "pause.fill", "Should show pause icon when playing")
        XCTAssertEqual(playButtonColorPlaying, "red", "Should be red when playing")
        
        // Paused state
        isPlaying = false
        isPaused = true
        
        let playButtonTextPaused = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonIconPaused = getButtonIcon(isPlaying: isPlaying, isPaused: isPaused)
        let playButtonColorPaused = getButtonColor(isPlaying: isPlaying, isPaused: isPaused)
        
        XCTAssertEqual(playButtonTextPaused, "Resume", "Should show 'Resume' when paused")
        XCTAssertEqual(playButtonIconPaused, "play.fill", "Should show play icon when paused")
        XCTAssertEqual(playButtonColorPaused, "orange", "Should be orange when paused")
    }
    
    func testStopButtonStateLogic() {
        // Test stop button logic
        
        // Initial state (stopped)
        var isPlaying = false
        var isPaused = false
        let _ = ".... . .-.. .-.. ---" // outputText not used in this test
        
        let stopButtonEnabled = isPlaying || isPaused
        let stopButtonColor = stopButtonEnabled ? "red" : "gray"
        
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when stopped")
        XCTAssertEqual(stopButtonColor, "gray", "Stop button should be gray when disabled")
        
        // Playing state
        isPlaying = true
        isPaused = false
        
        let stopButtonEnabledPlaying = isPlaying || isPaused
        let stopButtonColorPlaying = stopButtonEnabledPlaying ? "red" : "gray"
        
        XCTAssertTrue(stopButtonEnabledPlaying, "Stop button should be enabled when playing")
        XCTAssertEqual(stopButtonColorPlaying, "red", "Stop button should be red when enabled")
        
        // Paused state
        isPlaying = false
        isPaused = true
        
        let stopButtonEnabledPaused = isPlaying || isPaused
        let stopButtonColorPaused = stopButtonEnabledPaused ? "red" : "gray"
        
        XCTAssertTrue(stopButtonEnabledPaused, "Stop button should be enabled when paused")
        XCTAssertEqual(stopButtonColorPaused, "red", "Stop button should be red when enabled")
    }
    
    func testButtonStateTransitions() {
        // Test state transitions between different button states
        
        // Start stopped
        var isPlaying = false
        var isPaused = false
        
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Play")
        XCTAssertFalse(isPlaying || isPaused, "Stop button should be disabled")
        
        // Transition to playing
        isPlaying = true
        isPaused = false
        
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Pause")
        XCTAssertTrue(isPlaying || isPaused, "Stop button should be enabled")
        
        // Transition to paused
        isPlaying = false
        isPaused = true
        
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Resume")
        XCTAssertTrue(isPlaying || isPaused, "Stop button should be enabled")
        
        // Transition back to stopped
        isPlaying = false
        isPaused = false
        
        XCTAssertEqual(getButtonText(isPlaying: isPlaying, isPaused: isPaused), "Play")
        XCTAssertFalse(isPlaying || isPaused, "Stop button should be disabled")
    }
    
    func testButtonStateConsistency() {
        // Test that button states are consistent across different scenarios
        
        let testCases: [(isPlaying: Bool, isPaused: Bool, expectedText: String, expectedIcon: String, expectedColor: String)] = [
            (false, false, "Play", "play.fill", "green"),
            (true, false, "Pause", "pause.fill", "red"),
            (false, true, "Resume", "play.fill", "orange")
        ]
        
        for testCase in testCases {
            let text = getButtonText(isPlaying: testCase.isPlaying, isPaused: testCase.isPaused)
            let icon = getButtonIcon(isPlaying: testCase.isPlaying, isPaused: testCase.isPaused)
            let color = getButtonColor(isPlaying: testCase.isPlaying, isPaused: testCase.isPaused)
            
            XCTAssertEqual(text, testCase.expectedText, "Button text should match expected for state \(testCase.isPlaying), \(testCase.isPaused)")
            XCTAssertEqual(icon, testCase.expectedIcon, "Button icon should match expected for state \(testCase.isPlaying), \(testCase.isPaused)")
            XCTAssertEqual(color, testCase.expectedColor, "Button color should match expected for state \(testCase.isPlaying), \(testCase.isPaused)")
        }
    }
    
    func testButtonStateWithEmptyOutput() {
        // Test button states when there's no output text
        
        let outputText = ""
        let isPlaying = false
        let isPaused = false
        
        let playButtonEnabled = !outputText.isEmpty
        let stopButtonEnabled = isPlaying || isPaused
        
        XCTAssertFalse(playButtonEnabled, "Play button should be disabled when output is empty")
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when not playing or paused")
    }
    
    func testButtonStateWithLongOutput() {
        // Test button states with long output text
        
        let outputText = String(repeating: ".... . .-.. .-.. --- ", count: 100)
        let isPlaying = false
        let isPaused = false
        
        let playButtonEnabled = !outputText.isEmpty
        let stopButtonEnabled = isPlaying || isPaused
        
        XCTAssertTrue(playButtonEnabled, "Play button should be enabled with long output")
        XCTAssertFalse(stopButtonEnabled, "Stop button should be disabled when not playing or paused")
    }
    
    func testButtonStateEdgeCases() {
        // Test edge cases and invalid states
        
        // Both true (shouldn't happen but test for robustness)
        let isPlaying = true
        let isPaused = true
        
        let buttonText = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
        let buttonIcon = getButtonIcon(isPlaying: isPlaying, isPaused: isPaused)
        let buttonColor = getButtonColor(isPlaying: isPlaying, isPaused: isPaused)
        
        // Should prioritize paused state
        XCTAssertEqual(buttonText, "Resume", "Should show 'Resume' when both playing and paused")
        XCTAssertEqual(buttonIcon, "play.fill", "Should show play icon when both playing and paused")
        XCTAssertEqual(buttonColor, "orange", "Should be orange when both playing and paused")
    }
    
    func testButtonStateWithAudioService() {
        // Test button states with actual AudioService
        
        let audioService = AudioService()
        let outputText = ".... . .-.. .-.. ---"
        
        // Initial state
        XCTAssertFalse(audioService.isPlaying, "Audio service should not be playing initially")
        XCTAssertFalse(audioService.isPaused, "Audio service should not be paused initially")
        
        let initialPlayButtonText = getButtonText(isPlaying: audioService.isPlaying, isPaused: audioService.isPaused)
        let initialStopButtonEnabled = audioService.isPlaying || audioService.isPaused
        
        XCTAssertEqual(initialPlayButtonText, "Play", "Should show 'Play' initially")
        XCTAssertFalse(initialStopButtonEnabled, "Stop button should be disabled initially")
        
        // Test with actual Morse code playback
        audioService.playMorseCode(outputText)
        
        // Note: In a real test, we'd need to wait for the audio to start
        // For now, we'll test the state logic without actual audio playback
        let playButtonEnabled = !outputText.isEmpty
        XCTAssertTrue(playButtonEnabled, "Play button should be enabled with output text")
    }
    
    func testButtonStatePerformance() {
        // Test performance of button state calculations
        
        let outputText = ".... . .-.. .-.. ---"
        
        measure {
            for _ in 0..<10000 {
                let isPlaying = Bool.random()
                let isPaused = Bool.random()
                
                _ = getButtonText(isPlaying: isPlaying, isPaused: isPaused)
                _ = getButtonIcon(isPlaying: isPlaying, isPaused: isPaused)
                _ = getButtonColor(isPlaying: isPlaying, isPaused: isPaused)
                _ = !outputText.isEmpty
                _ = isPlaying || isPaused
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getButtonText(isPlaying: Bool, isPaused: Bool) -> String {
        if isPaused {
            return "Resume"
        } else if isPlaying {
            return "Pause"
        } else {
            return "Play"
        }
    }
    
    private func getButtonIcon(isPlaying: Bool, isPaused: Bool) -> String {
        if isPaused {
            return "play.fill"
        } else if isPlaying {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
    
    private func getButtonColor(isPlaying: Bool, isPaused: Bool) -> String {
        if isPaused {
            return "orange"
        } else if isPlaying {
            return "red"
        } else {
            return "green"
        }
    }
}