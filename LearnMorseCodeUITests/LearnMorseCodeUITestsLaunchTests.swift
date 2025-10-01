//
//  LearnMorseCodeUITestsLaunchTests.swift
//  LearnMorseCodeUITests
//
//  Created by Vivek Krishnan on 30/09/2025.
//

import XCTest

final class LearnMorseCodeUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for the app to fully load
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))

        // Take a screenshot of the launch screen (Morse Reference tab)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Morse Reference"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchOnTextToMorseTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for the app to load
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))
        
        // Navigate to Text to Morse tab
        let textToMorseTab = app.tabBars.buttons["Text↔Morse"]
        textToMorseTab.tap()
        
        // Wait for the view to load
        let convertButton = app.buttons["Convert"]
        XCTAssertTrue(convertButton.waitForExistence(timeout: 3.0))
        
        // Take a screenshot of the Text to Morse tab
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Text to Morse Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchOnSettingsTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for the app to load
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))
        
        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Wait for the view to load
        sleep(1) // Give time for settings to load
        
        // Take a screenshot of the Settings tab
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Settings Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchOnGameModeTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for the app to load
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))
        
        // Navigate to Game Mode tab
        let gameModeTab = app.tabBars.buttons["Game Mode"]
        gameModeTab.tap()
        
        // Wait for the view to load
        sleep(1) // Give time for game mode to load
        
        // Take a screenshot of the Game Mode tab
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Game Mode Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchOnVoiceToMorseTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for the app to load
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))
        
        // Navigate to Voice to Morse tab
        let voiceToMorseTab = app.tabBars.buttons["Voice to Morse"]
        voiceToMorseTab.tap()
        
        // Wait for the view to load
        sleep(1) // Give time for voice to morse to load
        
        // Take a screenshot of the Voice to Morse tab
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Voice to Morse Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
