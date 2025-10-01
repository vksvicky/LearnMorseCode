import Foundation
import AVFoundation

public class AudioService: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var audioFormat: AVAudioFormat!
    
    @Published public var isPlaying = false
    @Published public var speed: Double = 1.0 // Words per minute
    @Published public var volume: Float = 0.5
    
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
        
        let audioBuffer = generateMorseAudio(morseCode)
        playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: nil)
        
        if !playerNode.isPlaying {
            playerNode.play()
            isPlaying = true
        }
    }
    
    public func stop() {
        playerNode.stop()
        isPlaying = false
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
}
