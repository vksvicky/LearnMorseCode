import SwiftUI
import MorseCore
import LearnMorseUI

public struct MorseGameView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    @State private var gameMode = GameMode.learn
    @State private var currentCharacter = ""
    @State private var currentMorse = ""
    @State private var userAnswer = ""
    @State private var score = 0
    @State private var totalQuestions = 0
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var gameStarted = false
    @State private var gameStartTime: Date?
    
    public init() {}
    
    enum GameMode: String, CaseIterable {
        case learn = "Learn"
        case practice = "Practice"
        case challenge = "Challenge"
    }
    
    private let gameCharacters = [
        ("A", ".-"), ("B", "-..."), ("C", "-.-."), ("D", "-.."), ("E", "."),
        ("F", "..-."), ("G", "--."), ("H", "...."), ("I", ".."), ("J", ".---"),
        ("K", "-.-"), ("L", ".-.."), ("M", "--"), ("N", "-."), ("O", "---"),
        ("P", ".--."), ("Q", "--.-"), ("R", ".-."), ("S", "..."), ("T", "-"),
        ("U", "..-"), ("V", "...-"), ("W", ".--"), ("X", "-..-"), ("Y", "-.--"), ("Z", "--..")
    ]
    
    public var body: some View {
        VStack(spacing: 0) {
            if !gameStarted {
                // Game setup - Full width centered content
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 30) {
                        Text("Choose your game mode:")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Picker("Game Mode", selection: $gameMode) {
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 400)
                        
                        VStack(alignment: .center, spacing: 12) {
                            Text(gameModeDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 500)
                        }
                        
                        Button("Start Game") {
                            startGame()
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Game interface - Full width layout
                VStack(spacing: 0) {
                    // Score display
                    HStack {
                        Text("Score: \(score)/\(totalQuestions)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("End Game") {
                            endGame()
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Main game content - centered
                    VStack(spacing: 40) {
                        // Current character display
                        VStack(spacing: 20) {
                            Text("What is this character?")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            MorseCodeCard(character: "", morseCode: currentMorse) {
                                morseModel.playMorseCode(currentMorse)
                            }
                            .scaleEffect(1.5)
                        }
                        .padding(30)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(20)
                        .frame(maxWidth: 400)
                        
                        // Answer input
                        VStack(spacing: 20) {
                            Text("Your answer:")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            TextField("Enter character", text: $userAnswer)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                                .onSubmit {
                                    checkAnswer()
                                }
                        }
                        
                        // Action buttons
                        HStack(spacing: 30) {
                            Button("Play Sound") {
                                morseModel.playMorseCode(currentMorse)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 45)
                            .background(Color.green)
                            .cornerRadius(22)
                            
                            Button("Submit") {
                                checkAnswer()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 45)
                            .background(Color.blue)
                            .cornerRadius(22)
                            .disabled(userAnswer.isEmpty)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Result", isPresented: $showingResult) {
            Button("Next") {
                nextQuestion()
            }
        } message: {
            Text(isCorrect ? "Correct! 🎉" : "Incorrect. The answer was \(currentCharacter)")
        }
    }
    
    private var gameModeDescription: String {
        switch gameMode {
        case .learn:
            return "Learn mode: Take your time to study each character and its Morse code. No pressure!"
        case .practice:
            return "Practice mode: Test your knowledge with a mix of characters. Get immediate feedback."
        case .challenge:
            return "Challenge mode: Race against time! Answer as many as you can correctly."
        }
    }
    
    private func startGame() {
        gameStarted = true
        gameStartTime = Date()
        score = 0
        totalQuestions = 0
        nextQuestion()
    }
    
    private func endGame() {
        gameStarted = false
        currentCharacter = ""
        currentMorse = ""
        userAnswer = ""
    }
    
    private func nextQuestion() {
        guard let randomCharacter = gameCharacters.randomElement() else { return }
        currentCharacter = randomCharacter.0
        currentMorse = randomCharacter.1
        userAnswer = ""
        totalQuestions += 1
    }
    
    private func checkAnswer() {
        isCorrect = userAnswer.uppercased() == currentCharacter.uppercased()
        if isCorrect {
            score += 1
        }
        showingResult = true
    }
}