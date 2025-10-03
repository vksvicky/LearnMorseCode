import Foundation
import AVFoundation
import os.log

public class AudioService: ObservableObject {
    private let logger = Logger(subsystem: "club.cycleruncode.LearnMorseCode", category: "AudioService")
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var audioFormat: AVAudioFormat!
    
    @Published public var isPlaying = false
    @Published public var isPaused = false
    @Published public var speed: Double = 1.0 // Words per minute
    @Published public var volume: Float = 0.5
    @Published public var currentCharacterIndex: Int = -1 // -1 means no character highlighted
    @Published public var isElementPlaying: Bool = false // true when dot/dash is playing
    
    private var visualTimer: Timer?
    private var currentMorseCode: String = ""
    private var pauseStartTime: Date?
    private var totalPausedTime: Double = 0
    private var visualStartTime: Date?
    private struct TimingEvent {
        let time: Double
        let type: String
        let index: Int
    }
    private var timingEvents: [TimingEvent] = []
    
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
        logger.info("🔍 AudioService.playMorseCode called with: '\(morseCode)'")
        guard !morseCode.isEmpty else { 
            logger.info("🔍 Morse code is empty, returning")
            return 
        }
        
        // Stop any existing visual feedback
        stopVisualFeedback()
        
        // Store the current morse code for visual feedback
        currentMorseCode = morseCode
        logger.info("🔍 Stored morse code for visual feedback: '\(self.currentMorseCode)'")
        
        // Generate timing events for visual feedback
        generateTimingEvents(morseCode)
        
        // Start visual feedback
        startVisualFeedback()
        
        let audioBuffer = generateMorseAudio(morseCode)
        playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.stopVisualFeedback()
                self?.isPlaying = false
            }
        })
        
        if !playerNode.isPlaying {
            playerNode.play()
            isPlaying = true
            logger.info("🔍 Audio playback started, isPlaying = \(self.isPlaying)")
        } else {
            logger.info("🔍 Player node already playing")
        }
    }
    
    public func stop() {
        playerNode.stop()
        stopVisualFeedback()
        isPlaying = false
        isPaused = false
        totalPausedTime = 0
        pauseStartTime = nil
        visualStartTime = nil
    }
    
    public func pause() {
        guard isPlaying && !isPaused else { return }
        
        playerNode.pause()
        pauseStartTime = Date()
        isPaused = true
        isElementPlaying = false
        
        // Pause the visual timer
        visualTimer?.invalidate()
        visualTimer = nil
    }
    
    public func resume() {
        guard isPaused else { return }
        
        // Calculate total paused time
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
        }
        
        playerNode.play()
        isPaused = false
        
        // Resume visual feedback from where we left off
        resumeVisualFeedback()
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
        
        // Calculate timing based on speed (WPM)
        // Standard timing: 20 WPM = 1.2 seconds per word, 1 dot = 0.06 seconds
        let dotDuration = 1.2 / (speed * 20) // Base unit time
        let dashDuration = dotDuration * 3
        let elementGap = dotDuration
        let characterGap = dotDuration * 3
        let wordGap = dotDuration * 7
        
        var sampleIndex = 0
        var timeIndex: Float = 0
        
        for character in morseCode {
            switch character {
            case ".":
                // Play dot
                let dotSamples = Int(Float(dotDuration) * Float(sampleRate))
                for sampleIdx in 0..<dotSamples where sampleIndex + sampleIdx < Int(frameCount) {
                    let timeValue = Float(sampleIdx) / Float(sampleRate)
                    samples[sampleIndex + sampleIdx] = amplitude * sin(2.0 * Float.pi * frequency * timeValue)
                }
                sampleIndex += dotSamples
                timeIndex += Float(dotDuration)
                
                // Element gap
                let gapSamples = Int(Float(elementGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(elementGap)
                
            case "-":
                // Play dash
                let dashSamples = Int(Float(dashDuration) * Float(sampleRate))
                for sampleIdx in 0..<dashSamples where sampleIndex + sampleIdx < Int(frameCount) {
                    let timeValue = Float(sampleIdx) / Float(sampleRate)
                    samples[sampleIndex + sampleIdx] = amplitude * sin(2.0 * Float.pi * frequency * timeValue)
                }
                sampleIndex += dashSamples
                timeIndex += Float(dashDuration)
                
                // Element gap
                let gapSamples = Int(Float(elementGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(elementGap)
                
            case " ":
                // Character gap
                let gapSamples = Int(Float(characterGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(characterGap)
                
            case "/":
                // Word gap
                let gapSamples = Int(Float(wordGap) * Float(sampleRate))
                sampleIndex += gapSamples
                timeIndex += Float(wordGap)
                
            default:
                // Skip unknown characters
                continue
            }
        }
        
        return buffer
    }
    
    private func calculateDuration(_ morseCode: String) -> Double {
        let dotDuration = 1.2 / (speed * 20)
        let dashDuration = dotDuration * 3
        let elementGap = dotDuration
        let characterGap = dotDuration * 3
        let wordGap = dotDuration * 7
        
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
    
    // MARK: - Visual Feedback Methods
    
    private func generateTimingEvents(_ morseCode: String) {
        timingEvents.removeAll()
        
        let dotDuration = 1.2 / (speed * 20)
        let dashDuration = dotDuration * 3
        let elementGap = dotDuration
        let characterGap = dotDuration * 3
        let wordGap = dotDuration * 7
        
        var currentTime: Double = 0
        var visualIndex = 0 // Index for visual feedback (only dots and dashes)
        
        logger.info("🔍 Generating timing events for morse code: '\(morseCode)'")
        logger.info("🔍 Dot duration: \(dotDuration), Dash duration: \(dashDuration)")
        
        for character in morseCode {
            switch character {
            case ".":
                // Start of dot
                timingEvents.append(TimingEvent(time: currentTime, type: "start", index: visualIndex))
                currentTime += dotDuration
                // End of dot
                timingEvents.append(TimingEvent(time: currentTime, type: "end", index: visualIndex))
                currentTime += elementGap
                visualIndex += 1
                logger.info("🔍 Added dot events for visual index \(visualIndex-1) at time \(currentTime-dotDuration-elementGap)")
                
            case "-":
                // Start of dash
                timingEvents.append(TimingEvent(time: currentTime, type: "start", index: visualIndex))
                currentTime += dashDuration
                // End of dash
                timingEvents.append(TimingEvent(time: currentTime, type: "end", index: visualIndex))
                currentTime += elementGap
                visualIndex += 1
                logger.info("🔍 Added dash events for visual index \(visualIndex-1) at time \(currentTime-dashDuration-elementGap)")
                
            case " ":
                // Character gap - no visual feedback, don't increment visualIndex
                currentTime += characterGap
                
            case "/":
                // Word gap - no visual feedback, don't increment visualIndex
                currentTime += wordGap
                
            default:
                continue
            }
        }
        
        logger.info("🔍 Generated \(self.timingEvents.count) timing events")
    }
    
    private func startVisualFeedback() {
        guard !timingEvents.isEmpty else { 
            logger.info("🔍 No timing events to start visual feedback")
            return 
        }
        
        logger.info("🔍 Starting visual feedback with \(self.timingEvents.count) events")
        visualStartTime = Date()
        totalPausedTime = 0
        var eventIndex = 0
        
        visualTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let currentTime = Date().timeIntervalSince(self.visualStartTime!) - self.totalPausedTime
            
            // Check if we have more events to process
            while eventIndex < self.timingEvents.count {
                let event = self.timingEvents[eventIndex]
                
                if currentTime >= event.time {
                    self.logger.info("🔍 Processing event: \(event.type) for index \(event.index) at time \(currentTime)")
                    DispatchQueue.main.async {
                        if event.type == "start" {
                            self.currentCharacterIndex = event.index
                            self.isElementPlaying = true
                            self.logger.info("🔍 Set currentCharacterIndex to \(event.index), isElementPlaying to true")
                        } else if event.type == "end" {
                            self.isElementPlaying = false
                            self.logger.info("🔍 Set isElementPlaying to false")
                        }
                    }
                    eventIndex += 1
                } else {
                    break
                }
            }
            
            // If we've processed all events, stop the timer
            if eventIndex >= self.timingEvents.count {
                timer.invalidate()
                DispatchQueue.main.async {
                    self.currentCharacterIndex = -1
                    self.isElementPlaying = false
                }
            }
        }
    }
    
    private func stopVisualFeedback() {
        visualTimer?.invalidate()
        visualTimer = nil
        DispatchQueue.main.async {
            self.currentCharacterIndex = -1
            self.isElementPlaying = false
        }
        timingEvents.removeAll()
    }
    
    private func resumeVisualFeedback() {
        guard !timingEvents.isEmpty, let startTime = visualStartTime else { 
            logger.info("🔍 No timing events or start time to resume visual feedback")
            return 
        }
        
        logger.info("🔍 Resuming visual feedback with \(self.timingEvents.count) events")
        var eventIndex = 0
        
        // Find the current event index based on elapsed time
        let currentTime = Date().timeIntervalSince(startTime) - totalPausedTime
        for (index, event) in timingEvents.enumerated() {
            if event.time <= currentTime {
                eventIndex = index + 1
            } else {
                break
            }
        }
        
        visualTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let currentTime = Date().timeIntervalSince(self.visualStartTime!) - self.totalPausedTime
            
            // Check if we have more events to process
            while eventIndex < self.timingEvents.count {
                let event = self.timingEvents[eventIndex]
                
                if currentTime >= event.time {
                    self.logger.info("🔍 Processing event: \(event.type) for index \(event.index) at time \(currentTime)")
                    DispatchQueue.main.async {
                        if event.type == "start" {
                            self.currentCharacterIndex = event.index
                            self.isElementPlaying = true
                            self.logger.info("🔍 Set currentCharacterIndex to \(event.index), isElementPlaying to true")
                        } else if event.type == "end" {
                            self.isElementPlaying = false
                            self.logger.info("🔍 Set isElementPlaying to false")
                        }
                    }
                    eventIndex += 1
                } else {
                    break
                }
            }
            
            // If we've processed all events, stop the timer
            if eventIndex >= self.timingEvents.count {
                timer.invalidate()
                DispatchQueue.main.async {
                    self.currentCharacterIndex = -1
                    self.isElementPlaying = false
                }
            }
        }
    }
}
