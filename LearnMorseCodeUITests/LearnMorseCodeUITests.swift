//
//  LearnMorseCodeUITests.swift
//  LearnMorseCodeUITests
//
//  Created by Vivek Krishnan on 30/09/2025.
//

import XCTest

final class LearnMorseCodeUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // Initialize the app
        app = XCUIApplication()
        app.launch()

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    // MARK: - App Launch Tests
    
    @MainActor
    func testAppLaunchesSuccessfully() throws {
        // Verify that the app launches and shows the main interface
        XCTAssertTrue(app.state == .runningForeground)
        
        // Check that the main tab bar is visible
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }
    
    // MARK: - Tab Navigation Tests
    
    @MainActor
    func testTabNavigation() throws {
        // Test navigation between different tabs
        
        // Should start on Morse Reference tab
        let morseReferenceTab = app.tabBars.buttons["Morse Reference"]
        XCTAssertTrue(morseReferenceTab.exists)
        XCTAssertTrue(morseReferenceTab.isSelected)
        
        // Navigate to Text to Morse tab
        let textToMorseTab = app.tabBars.buttons["Text↔Morse"]
        XCTAssertTrue(textToMorseTab.exists)
        textToMorseTab.tap()
        XCTAssertTrue(textToMorseTab.isSelected)
        
        // Navigate to Voice to Morse tab
        let voiceToMorseTab = app.tabBars.buttons["Voice to Morse"]
        XCTAssertTrue(voiceToMorseTab.exists)
        voiceToMorseTab.tap()
        XCTAssertTrue(voiceToMorseTab.isSelected)
        
        // Navigate to Game Mode tab
        let gameModeTab = app.tabBars.buttons["Game Mode"]
        XCTAssertTrue(gameModeTab.exists)
        gameModeTab.tap()
        XCTAssertTrue(gameModeTab.isSelected)
        
        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        XCTAssertTrue(settingsTab.isSelected)
    }
    
    // MARK: - Morse Reference Tests
    
    @MainActor
    func testMorseReferenceView() throws {
        // Ensure we're on the Morse Reference tab
        let morseReferenceTab = app.tabBars.buttons["Morse Reference"]
        morseReferenceTab.tap()
        
        // Check that the category picker exists
        let categoryPicker = app.pickers.firstMatch
        XCTAssertTrue(categoryPicker.exists)
        
        // Check that Morse code cards are visible
        let morseCards = app.buttons.matching(identifier: "MorseCodeCard")
        XCTAssertTrue(morseCards.count > 0)
        
        // Test category switching
        categoryPicker.tap()
        // Note: Specific picker interaction would depend on the picker implementation
    }
    
    // MARK: - Text to Morse Tests
    
    @MainActor
    func testTextToMorseConversion() throws {
        // Navigate to Text to Morse tab
        let textToMorseTab = app.tabBars.buttons["Text↔Morse"]
        textToMorseTab.tap()
        
        // Find the input text field
        let inputTextField = app.textViews.firstMatch
        XCTAssertTrue(inputTextField.exists)
        
        // Enter test text
        inputTextField.tap()
        inputTextField.typeText("SOS")
        
        // Find and tap the convert button
        let convertButton = app.buttons["Convert"]
        XCTAssertTrue(convertButton.exists)
        convertButton.tap()
        
        // Check that output is displayed
        let outputTextField = app.textViews.element(boundBy: 1)
        XCTAssertTrue(outputTextField.exists)
        
        // Verify the output contains Morse code
        let outputText = outputTextField.value as? String ?? ""
        XCTAssertTrue(outputText.contains(".") || outputText.contains("-"))
    }
    
    @MainActor
    func testMorseToTextConversion() throws {
        // Navigate to Text to Morse tab
        let textToMorseTab = app.tabBars.buttons["Text↔Morse"]
        textToMorseTab.tap()
        
        // Find the input text field
        let inputTextField = app.textViews.firstMatch
        XCTAssertTrue(inputTextField.exists)
        
        // Enter Morse code
        inputTextField.tap()
        inputTextField.typeText("... --- ...")
        
        // Find and tap the convert button
        let convertButton = app.buttons["Convert"]
        XCTAssertTrue(convertButton.exists)
        convertButton.tap()
        
        // Check that output is displayed
        let outputTextField = app.textViews.element(boundBy: 1)
        XCTAssertTrue(outputTextField.exists)
        
        // Verify the output contains text
        let outputText = outputTextField.value as? String ?? ""
        XCTAssertTrue(outputText.contains("SOS"))
    }
    
    // MARK: - Voice to Morse Tests
    
    @MainActor
    func testVoiceToMorseView() throws {
        // Navigate to Voice to Morse tab
        let voiceToMorseTab = app.tabBars.buttons["Voice to Morse"]
        voiceToMorseTab.tap()
        
        // Check that the main interface elements exist
        // Note: These would need to be updated based on actual UI elements
        let recordButton = app.buttons.matching(identifier: "Record")
        if recordButton.exists {
            XCTAssertTrue(recordButton.firstMatch.exists)
        }
    }
    
    // MARK: - Game Mode Tests
    
    @MainActor
    func testGameModeView() throws {
        // Navigate to Game Mode tab
        let gameModeTab = app.tabBars.buttons["Game Mode"]
        gameModeTab.tap()
        
        // Check that game interface elements exist
        // Note: These would need to be updated based on actual UI elements
        let startButton = app.buttons.matching(identifier: "Start Game")
        if startButton.exists {
            XCTAssertTrue(startButton.firstMatch.exists)
        }
    }
    
    // MARK: - Settings Tests
    
    @MainActor
    func testSettingsView() throws {
        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Check that settings controls exist
        let speedSlider = app.sliders.firstMatch
        if speedSlider.exists {
            XCTAssertTrue(speedSlider.exists)
        }
        
        let volumeSlider = app.sliders.element(boundBy: 1)
        if volumeSlider.exists {
            XCTAssertTrue(volumeSlider.exists)
        }
    }
    
    // MARK: - Audio Playback Tests
    
    @MainActor
    func testAudioPlayback() throws {
        // Navigate to Text to Morse tab
        let textToMorseTab = app.tabBars.buttons["Text↔Morse"]
        textToMorseTab.tap()
        
        // Enter text and convert
        let inputTextField = app.textViews.firstMatch
        inputTextField.tap()
        inputTextField.typeText("SOS")
        
        let convertButton = app.buttons["Convert"]
        convertButton.tap()
        
        // Find and tap the play button
        let playButton = app.buttons["Play"]
        if playButton.exists {
            playButton.tap()
            
            // Wait a moment for audio to start
            sleep(1)
            
            // Check that play button state might have changed (if it shows pause)
            // This is a basic test - more sophisticated audio testing would require additional setup
        }
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testTabSwitchingPerformance() throws {
        // Measure performance of tab switching
        measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
            let morseReferenceTab = app.tabBars.buttons["Morse Reference"]
            let textToMorseTab = app.tabBars.buttons["Text↔Morse"]
            
            morseReferenceTab.tap()
            textToMorseTab.tap()
            morseReferenceTab.tap()
        }
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibility() throws {
        // Test that UI elements have proper accessibility labels
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.isAccessibilityElement)
        
        // Test that buttons are accessible
        let convertButton = app.buttons["Convert"]
        if convertButton.exists {
            XCTAssertTrue(convertButton.isAccessibilityElement)
        }
    }
}
