import XCTest
import AVFoundation
import Speech
@testable import MorseCore

@MainActor
final class AudioDeviceDetectionTests: XCTestCase {
    
    // MARK: - Test Setup
    
    private var mockPermissionManager: MockPermissionManager!
    private var mockAudioEngine: MockAudioEngine!
    private var mockAudioDeviceManager: MockAudioDeviceManager!
    
    override func setUp() {
        super.setUp()
        mockPermissionManager = MockPermissionManager()
        mockAudioEngine = MockAudioEngine()
        mockAudioDeviceManager = MockAudioDeviceManager()
    }
    
    override func tearDown() {
        mockPermissionManager = nil
        mockAudioEngine = nil
        mockAudioDeviceManager = nil
        super.tearDown()
    }
    
    // MARK: - Permission Tests
    
    func testMicrophonePermissionGranted() {
        let permissionManager = MockPermissionManager(microphonePermission: .granted)
        
        XCTAssertEqual(permissionManager.microphonePermissionStatus, .granted)
        
        let expectation = XCTestExpectation(description: "Permission request")
        permissionManager.requestMicrophonePermission { granted in
            XCTAssertTrue(granted, "Microphone permission should be granted")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMicrophonePermissionDenied() {
        let permissionManager = MockPermissionManager(microphonePermission: .denied)
        
        XCTAssertEqual(permissionManager.microphonePermissionStatus, .denied)
        
        let expectation = XCTestExpectation(description: "Permission request")
        permissionManager.requestMicrophonePermission { granted in
            XCTAssertFalse(granted, "Microphone permission should be denied")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSpeechRecognitionPermissionGranted() {
        let permissionManager = MockPermissionManager(speechRecognitionPermission: .authorized)
        
        XCTAssertEqual(permissionManager.speechRecognitionPermissionStatus, .authorized)
        
        let expectation = XCTestExpectation(description: "Permission request")
        permissionManager.requestSpeechRecognitionPermission { status in
            XCTAssertEqual(status, .authorized, "Speech recognition permission should be authorized")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSpeechRecognitionPermissionDenied() {
        let permissionManager = MockPermissionManager(speechRecognitionPermission: .denied)
        
        XCTAssertEqual(permissionManager.speechRecognitionPermissionStatus, .denied)
        
        let expectation = XCTestExpectation(description: "Permission request")
        permissionManager.requestSpeechRecognitionPermission { status in
            XCTAssertEqual(status, .denied, "Speech recognition permission should be denied")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Audio Device Tests
    
    func testAudioDeviceDetectionInitialization() {
        let devices = mockAudioDeviceManager.availableDevices
        
        XCTAssertFalse(devices.isEmpty, "Should have at least one mock device")
        XCTAssertEqual(devices.count, 3, "Should have 3 mock devices")
        
        XCTAssertTrue(devices.contains { $0.name == "Built-in Microphone" })
        XCTAssertTrue(devices.contains { $0.name == "External Microphone" })
        XCTAssertTrue(devices.contains { $0.name == "Virtual Audio Device" })
    }
    
    func testAudioDeviceTypeClassification() {
        let testCases: [(String, String)] = [
            ("Built-in Microphone", "Built-in"),
            ("External Microphone", "External"),
            ("Virtual Audio Device", "Virtual")
        ]
        
        for (deviceName, expectedType) in testCases {
            let device = mockAudioDeviceManager.availableDevices.first { $0.name == deviceName }
            XCTAssertNotNil(device, "Device '\(deviceName)' should exist")
            XCTAssertEqual(device?.type, expectedType, "Device '\(deviceName)' should be classified as '\(expectedType)'")
        }
    }
    
    func testAudioDeviceSelection() {
        let devices = mockAudioDeviceManager.availableDevices
        let firstDevice = devices.first!
        
        mockAudioDeviceManager.selectDevice(firstDevice)
        
        XCTAssertEqual(mockAudioDeviceManager.selectedDevice?.id, firstDevice.id, "Selected device should match")
        XCTAssertEqual(mockAudioDeviceManager.selectedDevice?.name, firstDevice.name, "Selected device name should match")
    }
    
    func testAudioDeviceDeduplication() {
        // Test that devices with same name are handled properly
        let device1 = MockAudioDeviceInfo(id: "1", name: "Built-in Microphone", type: "Built-in")
        let device2 = MockAudioDeviceInfo(id: "2", name: "Built-in Microphone", type: "Built-in") // Same name
        
        XCTAssertNotEqual(device1.id, device2.id, "Devices should have different IDs")
        XCTAssertEqual(device1.name, device2.name, "Devices should have same name")
    }
    
    // MARK: - Audio Engine Tests
    
    func testAudioEngineInitialization() {
        XCTAssertNotNil(mockAudioEngine, "Audio engine should be initialized")
        XCTAssertFalse(mockAudioEngine.isRunning, "Audio engine should not be running initially")
    }
    
    func testAudioEnginePreparation() {
        XCTAssertNoThrow(try mockAudioEngine.prepare(), "Should be able to prepare audio engine")
    }
    
    func testAudioEngineStartStop() {
        XCTAssertNoThrow(try mockAudioEngine.prepare(), "Should be able to prepare audio engine")
        XCTAssertNoThrow(try mockAudioEngine.start(), "Should be able to start audio engine")
        XCTAssertTrue(mockAudioEngine.isRunning, "Audio engine should be running")
        
        mockAudioEngine.stop()
        XCTAssertFalse(mockAudioEngine.isRunning, "Audio engine should not be running after stop")
    }
    
    func testAudioEngineStartWithoutPreparation() {
        XCTAssertThrowsError(try mockAudioEngine.start(), "Should throw error when starting unprepared engine")
    }
    
    func testAudioInputNodeBasicProperties() {
        // Test basic properties without accessing system audio hardware
        let inputNode = mockAudioEngine.inputNode
        
        // Test that we can access basic properties without crashing
        XCTAssertNotNil(inputNode, "Input node should exist")
        XCTAssertGreaterThanOrEqual(inputNode.numberOfInputs, 0, "Number of inputs should be non-negative")
    }
    
    // MARK: - Speech Recognition Tests
    
    func testSpeechRecognizerAvailability() {
        let speechRecognizer = MockSpeechRecognizer(isAvailable: true)
        
        XCTAssertTrue(speechRecognizer.isAvailable, "Speech recognizer should be available")
        XCTAssertTrue(speechRecognizer.supportsOnDeviceRecognition, "Should support on-device recognition")
    }
    
    func testSpeechRecognizerUnavailable() {
        let speechRecognizer = MockSpeechRecognizer(isAvailable: false)
        
        XCTAssertFalse(speechRecognizer.isAvailable, "Speech recognizer should not be available")
    }
    
    func testSpeechRecognitionRequestCreation() {
        let request = MockSpeechRecognitionRequest()
        
        XCTAssertNotNil(request, "Recognition request should be created")
        XCTAssertFalse(request.shouldReportPartialResults, "Partial results should be false by default")
        XCTAssertFalse(request.requiresOnDeviceRecognition, "On-device recognition should be false by default")
        XCTAssertEqual(request.taskHint, .unspecified, "Task hint should be unspecified by default")
    }
    
    func testSpeechRecognitionRequestConfiguration() {
        let request = MockSpeechRecognitionRequest()
        
        // Configure request
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        request.taskHint = .dictation
        
        XCTAssertTrue(request.shouldReportPartialResults, "Partial results should be enabled")
        XCTAssertFalse(request.requiresOnDeviceRecognition, "On-device recognition should be disabled")
        XCTAssertEqual(request.taskHint, .dictation, "Task hint should be dictation")
    }
    
    func testSpeechRecognitionRequestAudioAppending() {
        let request = MockSpeechRecognitionRequest()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)!
        
        XCTAssertEqual(request.appendedBufferCount, 0, "Should start with no buffers")
        
        request.append(buffer)
        
        XCTAssertEqual(request.appendedBufferCount, 1, "Should have one buffer after appending")
    }
    
    // MARK: - Audio Buffer Tests
    
    func testAudioBufferCreation() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)
        
        XCTAssertNotNil(buffer, "Buffer should be created successfully")
        XCTAssertEqual(buffer?.frameCapacity, 1024, "Buffer capacity should match requested size")
    }
    
    func testAudioBufferWithDifferentFormats() {
        // Test buffer creation with different valid formats
        let format1 = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let format2 = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 2)!
        
        let buffer1 = AVAudioPCMBuffer(pcmFormat: format1, frameCapacity: 1024)
        let buffer2 = AVAudioPCMBuffer(pcmFormat: format2, frameCapacity: 2048)
        
        XCTAssertNotNil(buffer1, "Buffer should be created with 44.1kHz mono format")
        XCTAssertNotNil(buffer2, "Buffer should be created with 48kHz stereo format")
        
        XCTAssertEqual(buffer1?.frameCapacity, 1024, "Buffer 1 capacity should match")
        XCTAssertEqual(buffer2?.frameCapacity, 2048, "Buffer 2 capacity should match")
    }
    
    // MARK: - Performance Tests
    
    func testAudioDeviceDetectionPerformance() {
        measure {
            _ = MockAudioDeviceManager()
        }
    }
    
    func testDeviceTypeClassificationPerformance() {
        let testCases = ["Built-in Microphone", "External Microphone", "Virtual Audio Device", "Unknown Device"]
        
        measure {
            for _ in 0..<1000 {
                for deviceName in testCases {
                    _ = classifyDeviceType(deviceName)
                }
            }
        }
    }
    
    func testPermissionCheckPerformance() {
        let permissionManager = MockPermissionManager()
        
        measure {
            for _ in 0..<1000 {
                _ = permissionManager.microphonePermissionStatus
                _ = permissionManager.speechRecognitionPermissionStatus
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func classifyDeviceType(_ deviceName: String) -> String {
        if deviceName.contains("Built-in") || deviceName.contains("Internal") {
            return "Built-in"
        } else if deviceName.contains("External") || deviceName.contains("USB") || deviceName.contains("Headset") {
            return "External"
        } else if deviceName.contains("Virtual") || deviceName.contains("Boom") || deviceName.contains("MMAudio") || deviceName.contains("Loopback") {
            return "Virtual"
        } else {
            return "Unknown"
        }
    }
}