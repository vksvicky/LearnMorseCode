import Foundation
import AVFoundation
import Speech

// MARK: - Cross-Platform Permission Types

public enum MockMicrophonePermission: String, CaseIterable {
    case granted = "granted"
    case denied = "denied"
    case undetermined = "undetermined"
    
    #if os(iOS)
    var avAudioSessionPermission: AVAudioSession.RecordPermission {
        switch self {
        case .granted: return .granted
        case .denied: return .denied
        case .undetermined: return .undetermined
        }
    }
    #endif
}

// MARK: - Mock Permission Manager

public protocol PermissionManagerProtocol {
    var microphonePermissionStatus: MockMicrophonePermission { get }
    var speechRecognitionPermissionStatus: SFSpeechRecognizerAuthorizationStatus { get }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void)
    func requestSpeechRecognitionPermission(completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void)
}

public class MockPermissionManager: PermissionManagerProtocol {
    public var microphonePermissionStatus: MockMicrophonePermission
    public var speechRecognitionPermissionStatus: SFSpeechRecognizerAuthorizationStatus
    
    public init(
        microphonePermission: MockMicrophonePermission = .granted,
        speechRecognitionPermission: SFSpeechRecognizerAuthorizationStatus = .authorized
    ) {
        self.microphonePermissionStatus = microphonePermission
        self.speechRecognitionPermissionStatus = speechRecognitionPermission
    }
    
    public func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            completion(self.microphonePermissionStatus == .granted)
        }
    }
    
    public func requestSpeechRecognitionPermission(completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        DispatchQueue.main.async {
            completion(self.speechRecognitionPermissionStatus)
        }
    }
}

// MARK: - Mock Audio Engine

public protocol AudioEngineProtocol {
    var inputNode: AVAudioInputNode { get }
    var isRunning: Bool { get }
    
    func prepare() throws
    func start() throws
    func stop()
}

public class MockAudioEngine: AudioEngineProtocol {
    public let inputNode: AVAudioInputNode
    public private(set) var isRunning: Bool = false
    public private(set) var isPrepared: Bool = false
    
    // Static cached input node to avoid creating multiple real engines
    private static let cachedInputNode: AVAudioInputNode = {
        let engine = AVAudioEngine()
        return engine.inputNode
    }()
    
    public init(inputNode: AVAudioInputNode? = nil) {
        // Use provided input node or the cached one to avoid multiple system calls
        self.inputNode = inputNode ?? MockAudioEngine.cachedInputNode
    }
    
    public func prepare() throws {
        isPrepared = true
    }
    
    public func start() throws {
        guard isPrepared else {
            throw NSError(domain: "MockAudioEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Engine not prepared"])
        }
        isRunning = true
    }
    
    public func stop() {
        isRunning = false
    }
}

// MARK: - Mock Audio Input Node

public protocol AudioInputNodeProtocol {
    var numberOfInputs: AVAudioNodeBus { get }
    func outputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat
    func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, block: @escaping AVAudioNodeTapBlock) throws
    func removeTap(onBus bus: AVAudioNodeBus)
}

public class MockAudioInputNode: AudioInputNodeProtocol {
    public let numberOfInputs: AVAudioNodeBus
    private var installedTaps: [AVAudioNodeBus: Bool] = [:]
    
    public init(numberOfInputs: AVAudioNodeBus = 1) {
        self.numberOfInputs = numberOfInputs
    }
    
    public func outputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat {
        return AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    }
    
    public func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, block: @escaping AVAudioNodeTapBlock) throws {
        guard let format = format, format.sampleRate > 0 && format.channelCount > 0 else {
            throw NSError(domain: "MockAudioInputNode", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid format"])
        }
        installedTaps[bus] = true
    }
    
    public func removeTap(onBus bus: AVAudioNodeBus) {
        installedTaps.removeValue(forKey: bus)
    }
    
    public func isTapInstalled(onBus bus: AVAudioNodeBus) -> Bool {
        return installedTaps[bus] ?? false
    }
}

// MARK: - Mock Speech Recognizer

public protocol SpeechRecognizerProtocol {
    var isAvailable: Bool { get }
    var supportsOnDeviceRecognition: Bool { get }
}

public class MockSpeechRecognizer: SpeechRecognizerProtocol {
    public let isAvailable: Bool
    public let supportsOnDeviceRecognition: Bool
    
    public init(isAvailable: Bool = true, supportsOnDeviceRecognition: Bool = true) {
        self.isAvailable = isAvailable
        self.supportsOnDeviceRecognition = supportsOnDeviceRecognition
    }
}

// MARK: - Mock Speech Recognition Request

public protocol SpeechRecognitionRequestProtocol {
    var shouldReportPartialResults: Bool { get set }
    var requiresOnDeviceRecognition: Bool { get set }
    var taskHint: SFSpeechRecognitionTaskHint { get set }
    
    func append(_ audioPCMBuffer: AVAudioPCMBuffer)
    func endAudio()
}

public class MockSpeechRecognitionRequest: SpeechRecognitionRequestProtocol {
    public var shouldReportPartialResults: Bool = false
    public var requiresOnDeviceRecognition: Bool = false
    public var taskHint: SFSpeechRecognitionTaskHint = .unspecified
    private var audioBuffers: [AVAudioPCMBuffer] = []
    
    public init() {}
    
    public func append(_ audioPCMBuffer: AVAudioPCMBuffer) {
        audioBuffers.append(audioPCMBuffer)
    }
    
    public func endAudio() {
        // Mock implementation
    }
    
    public var appendedBufferCount: Int {
        return audioBuffers.count
    }
}

// MARK: - Mock Audio Device Info

public struct MockAudioDeviceInfo: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let type: String
    public let isAvailable: Bool
    
    public init(id: String, name: String, type: String, isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.type = type
        self.isAvailable = isAvailable
    }
    
    public static func == (lhs: MockAudioDeviceInfo, rhs: MockAudioDeviceInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Mock Audio Device Manager

public protocol AudioDeviceManagerProtocol {
    var availableDevices: [MockAudioDeviceInfo] { get }
    var selectedDevice: MockAudioDeviceInfo? { get set }
    
    func loadAvailableDevices()
    func selectDevice(_ device: MockAudioDeviceInfo)
}

public class MockAudioDeviceManager: AudioDeviceManagerProtocol {
    public private(set) var availableDevices: [MockAudioDeviceInfo] = []
    public var selectedDevice: MockAudioDeviceInfo?
    
    public init() {
        loadAvailableDevices()
    }
    
    public func loadAvailableDevices() {
        availableDevices = [
            MockAudioDeviceInfo(id: "builtin", name: "Built-in Microphone", type: "Built-in"),
            MockAudioDeviceInfo(id: "external", name: "External Microphone", type: "External"),
            MockAudioDeviceInfo(id: "virtual", name: "Virtual Audio Device", type: "Virtual")
        ]
        
        if selectedDevice == nil {
            selectedDevice = availableDevices.first
        }
    }
    
    public func selectDevice(_ device: MockAudioDeviceInfo) {
        selectedDevice = device
    }
}
