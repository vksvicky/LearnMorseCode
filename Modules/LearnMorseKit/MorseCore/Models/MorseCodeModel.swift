import Combine
import Foundation

@MainActor
public final class MorseCodeModel: ObservableObject {
    @Published public var inputText: String = ""
    @Published public var morseCodeOutput: String = ""
    private let encoder: MorseEncoding
    public let audioService: AudioService
    public let progressTracker: ProgressTracker
    public let achievementManager: AchievementManager
    
    public init(encoder: MorseEncoding = MorseEncoder()) { 
        self.encoder = encoder
        self.audioService = AudioService()
        self.progressTracker = ProgressTracker()
        self.achievementManager = AchievementManager()
    }
    
    public func textToMorseCode(_ text: String) -> String {
        (try? encoder.encode(text)) ?? ""
    }
    
    public func playMorseCode(_ morseCode: String) {
        audioService.playMorseCode(morseCode)
    }
    
    public func recordGameSession(score: Int, totalQuestions: Int, mode: String, duration: TimeInterval) {
        let session = PracticeSession(
            date: Date(),
            mode: mode,
            score: score,
            totalQuestions: totalQuestions,
            duration: duration
        )
        
        progressTracker.addSession(session)
        achievementManager.checkAchievements(with: progressTracker)
    }
}
