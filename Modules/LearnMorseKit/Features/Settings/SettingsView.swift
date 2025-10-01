import SwiftUI
import MorseCore

public struct SettingsView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    @State private var showingResetAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Audio Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Speed (WPM)")
                            Spacer()
                            Text("\(Int(morseModel.audioService.speed))")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $morseModel.audioService.speed,
                            in: 5...25,
                            step: 1
                        )
                        .accentColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(Int(morseModel.audioService.volume * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $morseModel.audioService.volume,
                            in: 0...1,
                            step: 0.1
                        )
                        .accentColor(.blue)
                    }
                }
                
                Section("Learning Preferences") {
                    NavigationLink("Practice History") {
                        PracticeHistoryView()
                    }
                    
                    NavigationLink("Achievements") {
                        AchievementsView()
                    }
                }
                
                Section("Progress") {
                    HStack {
                        Text("Total Practice Time")
                        Spacer()
                        Text(formatTime(morseModel.progressTracker.totalPracticeTime))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Best Score")
                        Spacer()
                        Text("\(morseModel.progressTracker.bestScore)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Current Streak")
                        Spacer()
                        Text("\(morseModel.progressTracker.getStreak()) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Average Accuracy")
                        Spacer()
                        Text("\(Int(morseModel.progressTracker.getAverageAccuracy() * 100))%")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset All Settings") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    resetSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will reset all settings to their default values. This action cannot be undone.")
            }
        }
    }
    
    private func resetSettings() {
        morseModel.audioService.speed = 1.0
        morseModel.audioService.volume = 0.5
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct PracticeHistoryView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    
    var body: some View {
        List {
            if morseModel.progressTracker.practiceSessions.isEmpty {
                VStack {
                    Text("No practice sessions yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Start playing the game to track your progress!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(morseModel.progressTracker.getRecentSessions()) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(session.mode)
                                .font(.headline)
                            Spacer()
                            Text("\(session.score)/\(session.totalQuestions)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(session.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(session.accuracy * 100))% accuracy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Practice History")
    }
}

struct AchievementsView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    
    var body: some View {
        List {
            ForEach(morseModel.achievementManager.achievements) { achievement in
                HStack {
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.headline)
                            .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                        
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Achievements")
    }
}
