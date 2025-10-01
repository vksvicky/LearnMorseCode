//
//  ContentView.swift
//  LearnMorseCode
//
//  Created by Vivek Krishnan on 30/09/2025.
//

import SwiftUI
import MorseReference
import TextToMorse
import VoiceToMorse
import GameMode

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(
                    title: "Reference",
                    icon: "book.fill",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                TabButton(
                    title: "Text↔Morse",
                    icon: "arrow.left.arrow.right",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                TabButton(
                    title: "Voice→Morse",
                    icon: "mic.fill",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
                
                TabButton(
                    title: "Game",
                    icon: "gamecontroller.fill",
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.windowBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.separatorColor)),
                alignment: .bottom
            )
            
            // Content Area - Full Width
            Group {
                switch selectedTab {
                case 0:
                    MorseReferenceView()
                case 1:
                    TextToMorseView()
                case 2:
                    VoiceToMorseView()
                case 3:
                    MorseGameView()
                default:
                    MorseReferenceView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
