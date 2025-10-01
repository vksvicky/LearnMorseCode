import Foundation

public struct Achievement: Codable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String
    public let isUnlocked: Bool
    public let unlockedDate: Date?
    public let requirement: AchievementRequirement
    
    public init(id: String, title: String, description: String, icon: String, requirement: AchievementRequirement) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.requirement = requirement
        self.isUnlocked = false
        self.unlockedDate = nil
    }
}

public enum AchievementRequirement: Codable {
    case practiceSessions(count: Int)
    case totalScore(score: Int)
    case accuracy(percentage: Double)
    case streak(days: Int)
    case charactersLearned(count: Int)
    case practiceTime(hours: Double)
}

public class AchievementManager: ObservableObject {
    @Published public var achievements: [Achievement] = []
    @Published public var unlockedAchievements: [Achievement] = []
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "Achievements"
    
    public init() {
        initializeAchievements()
        loadAchievements()
    }
    
    private func initializeAchievements() {
        achievements = [
            Achievement(
                id: "first_session",
                title: "Getting Started",
                description: "Complete your first practice session",
                icon: "star.fill",
                requirement: .practiceSessions(count: 1)
            ),
            Achievement(
                id: "perfect_score",
                title: "Perfect Score",
                description: "Get 100% accuracy in a practice session",
                icon: "checkmark.circle.fill",
                requirement: .accuracy(percentage: 1.0)
            ),
            Achievement(
                id: "week_streak",
                title: "Week Warrior",
                description: "Practice for 7 consecutive days",
                icon: "flame.fill",
                requirement: .streak(days: 7)
            ),
            Achievement(
                id: "speed_demon",
                title: "Speed Demon",
                description: "Complete 50 practice sessions",
                icon: "bolt.fill",
                requirement: .practiceSessions(count: 50)
            ),
            Achievement(
                id: "dedicated_learner",
                title: "Dedicated Learner",
                description: "Practice for 10 hours total",
                icon: "clock.fill",
                requirement: .practiceTime(hours: 10)
            ),
            Achievement(
                id: "alphabet_master",
                title: "Alphabet Master",
                description: "Learn all 26 letters",
                icon: "textformat.abc",
                requirement: .charactersLearned(count: 26)
            )
        ]
    }
    
    public func checkAchievements(with progress: ProgressTracker) {
        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked && isRequirementMet(achievements[i].requirement, progress: progress) {
                unlockAchievement(at: i)
            }
        }
    }
    
    private func isRequirementMet(_ requirement: AchievementRequirement, progress: ProgressTracker) -> Bool {
        switch requirement {
        case .practiceSessions(let count):
            return progress.practiceSessions.count >= count
        case .totalScore(let score):
            return progress.practiceSessions.reduce(0) { $0 + $1.score } >= score
        case .accuracy(let percentage):
            return progress.getAverageAccuracy() >= percentage
        case .streak(let days):
            return progress.getStreak() >= days
        case .charactersLearned(let count):
            return progress.charactersLearned.count >= count
        case .practiceTime(let hours):
            return progress.totalPracticeTime >= (hours * 3600)
        }
    }
    
    private func unlockAchievement(at index: Int) {
        var achievement = achievements[index]
        achievement = Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            requirement: achievement.requirement
        )
        
        achievements[index] = achievement
        unlockedAchievements.append(achievement)
        saveAchievements()
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = loadedAchievements
            unlockedAchievements = achievements.filter { $0.isUnlocked }
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }
    
    public func resetAchievements() {
        achievements.removeAll()
        unlockedAchievements.removeAll()
        initializeAchievements()
        saveAchievements()
    }
}
