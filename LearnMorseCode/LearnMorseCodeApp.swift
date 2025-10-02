//
//  LearnMorseCodeApp.swift
//  LearnMorseCode
//
//  Created by Vivek Krishnan on 30/09/2025.
//

import SwiftUI
import MorseCore

@main
struct LearnMorseCodeApp: App {
    @StateObject private var morseModel = MorseCodeModel()
    
    var body: some Scene {
        WindowGroup("Learn Morse Code") {
            ContentView()
                .environmentObject(morseModel)
        }
    }
}
