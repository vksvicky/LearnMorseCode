import Foundation
import AVFoundation

public class AudioService: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var audioFormat: AVAudioFormat!
    
    @Published public var isPlaying = false
    @Published public var isPaused = false
    @Published public var speed: Double = 1.0 // Words per minute
    @Published public var volume: Float = 0.5
    
    private var currentMorseCode = ""
    private var currentPosition = 0
    private var playbackTimer: Timer?
    private var visualStartTime: Date?
    private var totalDuration: Double = 0
    private var characterTimings: [(character: Character, startTime: Double, duration: Double)] = []
    
    // Shared timing constants - used by both audio and visual feedback
    private var dotDuration: Double { 1.2 / (speed * 20) }
    private var dashDuration: Double { dotDuration * 3 }
    private var elementGap: Double { dotDuration }
    private var characterGap: Double { dotDuration * 3 }
    private var wordGap: Double { dotDuration * 7 }
    
    public init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    public func playMorseCode(_ morseCode: String) {
        guard !morseCode.isEmpty else { return }
        
        // If already playing the same code, just resume
        if isPaused && morseCode == currentMorseCode {
            resume()
            return
        }
        
        // Stop any current playback
        stop()
        
        currentMorseCode = morseCode
        currentPosition = 0
        totalDuration = calculateDuration(morseCode)
        characterTimings = calculateCharacterTimings(morseCode)
        
        let audioBuffer = generateMorseAudio(morseCode)
        
        // Use simple Date-based timing for visual feedback
        visualStartTime = Date()
        
        playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.isPaused = false
                self?.currentPosition = 0
                self?.playbackTimer?.invalidate()
                self?.visualStartTime = nil
            }
        })
        
        playerNode.play()
        isPlaying = true
        isPaused = false
        
        // Start timing for visual feedback
        startPlaybackTimer()
    }
    
    public func pause() {
        guard isPlaying && !isPaused else { return }
        
        playerNode.pause()
        isPaused = true
        playbackTimer?.invalidate()
    }
    
    public func resume() {
        guard isPaused else { return }
        
        // Update the visual start time to account for the pause
        if let visualStartTime = visualStartTime {
            let elapsed = Date().timeIntervalSince(visualStartTime)
            self.visualStartTime = Date().addingTimeInterval(-elapsed)
        }
        
        playerNode.play()
        isPaused = false
        startPlaybackTimer()
    }
    
    public func stop() {
        playerNode.stop()
        isPlaying = false
        isPaused = false
        currentPosition = 0
        playbackTimer?.invalidate()
        visualStartTime = nil
        totalDuration = 0
        characterTimings = []
    }
    
    // MARK: - Timing and Visual Feedback
    
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Use simple Date-based timing for visual feedback
            guard let visualStartTime = self.visualStartTime else {
                return
            }
            
            let elapsed = Date().timeIntervalSince(visualStartTime)
            
            // Find the current character based on timing
            var newPosition = 0
            for (index, timing) in self.characterTimings.enumerated() {
                if elapsed >= timing.startTime && elapsed < timing.startTime + timing.duration {
                    newPosition = index
                    break
                } else if elapsed >= timing.startTime + timing.duration {
                    newPosition = index + 1
                }
            }
            
            // Clamp to valid range
            newPosition = min(newPosition, self.currentMorseCode.count)
            
            if newPosition != self.currentPosition {
                self.currentPosition = newPosition
            }
            
            // Stop timer if we've reached the end
            if newPosition >= self.currentMorseCode.count {
                timer.invalidate()
            }
        }
    }
    
    public func getCurrentPosition() -> Int {
        return currentPosition
    }
    
    
    private func generateMorseAudio(_ morseCode: String) -> AVAudioPCMBuffer {
        let sampleRate = audioFormat.sampleRate
        let duration = calculateDuration(morseCode)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            fatalError("Failed to create audio buffer")
        }
        
        buffer.frameLength = frameCount
        
        let samples = buffer.floatChannelData![0]
        let frequency: Float = 600.0 // Hz
        let amplitude: Float = volume
        
        // Use shared timing constants for consistency with visual feedback
        
        var sampleIndex = 0
        var timeIndex: Float = 0
        
        for character in morseCode {
            switch character {
            case ".":
                // Play dot
                let dotSamples = Int(Float(self.dotDuration) * Float(sampleRate))
                for sampleIdx in 0..<dotSamples where sampleIndex + sampleIdx < Int(frameCount) {
                    let timeValue = Float(sampleIdx) / Float(sampleRate)
                    samples[sampleIndex + sampleIdx] = amplitude * sin(2.0 * Float.pi * frequency * timeValue)
                }
                sampleIndex += dotSamples
                timeIndex += Float(self.dotDuration)
                
                // Element gap
                let gapSamples = Int(Float(self.elementGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(self.elementGap)
                
            case "-":
                // Play dash
                let dashSamples = Int(Float(self.dashDuration) * Float(sampleRate))
                for sampleIdx in 0..<dashSamples where sampleIndex + sampleIdx < Int(frameCount) {
                    let timeValue = Float(sampleIdx) / Float(sampleRate)
                    samples[sampleIndex + sampleIdx] = amplitude * sin(2.0 * Float.pi * frequency * timeValue)
                }
                sampleIndex += dashSamples
                timeIndex += Float(self.dashDuration)
                
                // Element gap
                let gapSamples = Int(Float(self.elementGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(self.elementGap)
                
            case " ":
                // Character gap
                let gapSamples = Int(Float(self.characterGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(self.characterGap)
                
            case "/":
                // Word gap
                let gapSamples = Int(Float(self.wordGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(self.wordGap)
                
            default:
                // Skip unknown characters
                continue
            }
        }
        
        return buffer
    }
    
    private func calculateDuration(_ morseCode: String) -> Double {
        var totalDuration: Double = 0
        
        for character in morseCode {
            switch character {
            case ".":
                totalDuration += dotDuration + elementGap
            case "-":
                totalDuration += dashDuration + elementGap
            case " ":
                totalDuration += characterGap
            case "/":
                totalDuration += wordGap
            default:
                continue
            }
        }
        
        return totalDuration
    }
    
    private func calculateCharacterTimings(_ morseCode: String) -> [(character: Character, startTime: Double, duration: Double)] {
        var timings: [(character: Character, startTime: Double, duration: Double)] = []
        var currentTime: Double = 0
        
        for character in morseCode {
            let startTime = currentTime
            var duration: Double = 0
            
            switch character {
            case ".":
                duration = dotDuration + elementGap
            case "-":
                duration = dashDuration + elementGap
            case " ":
                duration = characterGap
            case "/":
                duration = wordGap
            default:
                continue
            }
            
            timings.append((character: character, startTime: startTime, duration: duration))
            currentTime += duration
        }
        
        return timings
    }
}
