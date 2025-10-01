import Foundation

public struct PracticeSession: Codable, Identifiable {
    public let id = UUID()
    public let date: Date
    public let mode: String
    public let score: Int
    public let totalQuestions: Int
    public let duration: TimeInterval
    
    public var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions)
    }
}

public class ProgressTracker: ObservableObject {
    @Published public var practiceSessions: [PracticeSession] = []
    @Published public var totalPracticeTime: TimeInterval = 0
    @Published public var bestScore: Int = 0
    @Published public var charactersLearned: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "PracticeSessions"
    private let totalTimeKey = "TotalPracticeTime"
    private let bestScoreKey = "BestScore"
    private let charactersKey = "CharactersLearned"
    
    public init() {
        loadProgress()
    }
    
    public func addSession(_ session: PracticeSession) {
        practiceSessions.append(session)
        totalPracticeTime += session.duration
        
        if session.score > bestScore {
            bestScore = session.score
        }
        
        // Mark characters as learned if accuracy is high enough
        if session.accuracy >= 0.8 {
            // This is a simplified approach - in a real app, you'd track specific characters
            charactersLearned.insert("General")
        }
        
        saveProgress()
    }
    
    public func getRecentSessions(limit: Int = 10) -> [PracticeSession] {
        return Array(practiceSessions.suffix(limit))
    }
    
    public func getAverageAccuracy() -> Double {
        guard !practiceSessions.isEmpty else { return 0 }
        let totalAccuracy = practiceSessions.reduce(0) { $0 + $1.accuracy }
        return totalAccuracy / Double(practiceSessions.count)
    }
    
    public func getStreak() -> Int {
        // Calculate consecutive days with practice
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        
        for session in practiceSessions.reversed() {
            let daysBetween = calendar.dateComponents([.day], from: session.date, to: today).day ?? 0
            if daysBetween <= 1 {
                streak += 1
                if daysBetween == 1 {
                    break
                }
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func loadProgress() {
        if let sessionsData = userDefaults.data(forKey: sessionsKey),
           let sessions = try? JSONDecoder().decode([PracticeSession].self, from: sessionsData) {
            practiceSessions = sessions
        }
        
        totalPracticeTime = userDefaults.double(forKey: totalTimeKey)
        bestScore = userDefaults.integer(forKey: bestScoreKey)
        
        if let charactersData = userDefaults.data(forKey: charactersKey),
           let characters = try? JSONDecoder().decode(Set<String>.self, from: charactersData) {
            charactersLearned = characters
        }
    }
    
    private func saveProgress() {
        if let sessionsData = try? JSONEncoder().encode(practiceSessions) {
            userDefaults.set(sessionsData, forKey: sessionsKey)
        }
        
        userDefaults.set(totalPracticeTime, forKey: totalTimeKey)
        userDefaults.set(bestScore, forKey: bestScoreKey)
        
        if let charactersData = try? JSONEncoder().encode(charactersLearned) {
            userDefaults.set(charactersData, forKey: charactersKey)
        }
    }
    
    public func resetProgress() {
        practiceSessions.removeAll()
        totalPracticeTime = 0
        bestScore = 0
        charactersLearned.removeAll()
        saveProgress()
    }
}
