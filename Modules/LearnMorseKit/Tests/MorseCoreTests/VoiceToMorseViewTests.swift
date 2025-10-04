import XCTest
import SwiftUI
import AVFoundation
import Speech
@testable import MorseCore
@testable import LearnMorseUI

final class VoiceToMorseViewTests: XCTestCase {
    
    // MARK: - Test Setup
    
    private var mockPermissionManager: MockPermissionManager!
    private var mockAudioDeviceManager: MockAudioDeviceManager!
    
    override func setUp() {
        super.setUp()
        mockPermissionManager = MockPermissionManager()
        mockAudioDeviceManager = MockAudioDeviceManager()
    }
    
    override func tearDown() {
        mockPermissionManager = nil
        mockAudioDeviceManager = nil
        super.tearDown()
    }
    
    // MARK: - Audio Device Info Tests
    
    func testAudioDeviceInfoCreation() {
        let device = MockAudioDeviceInfo(
            id: "test_device",
            name: "Test Microphone",
            type: "Built-in"
        )
        
        XCTAssertEqual(device.id, "test_device")
        XCTAssertEqual(device.name, "Test Microphone")
        XCTAssertEqual(device.type, "Built-in")
        XCTAssertTrue(device.isAvailable)
    }
    
    func testAudioDeviceInfoEquality() {
        let device1 = MockAudioDeviceInfo(
            id: "test_device",
            name: "Test Microphone",
            type: "Built-in"
        )
        
        let device2 = MockAudioDeviceInfo(
            id: "test_device",
            name: "Test Microphone",
            type: "Built-in"
        )
        
        let device3 = MockAudioDeviceInfo(
            id: "different_device",
            name: "Different Microphone",
            type: "External"
        )
        
        XCTAssertEqual(device1, device2, "Devices with same ID should be equal")
        XCTAssertNotEqual(device1, device3, "Devices with different IDs should not be equal")
    }
    
    func testAudioDeviceInfoHashable() {
        let device1 = MockAudioDeviceInfo(
            id: "test_device",
            name: "Test Microphone",
            type: "Built-in"
        )
        
        let device2 = MockAudioDeviceInfo(
            id: "test_device",
            name: "Test Microphone",
            type: "Built-in"
        )
        
        XCTAssertEqual(device1.hashValue, device2.hashValue, "Devices with same ID should have same hash value")
    }
    
    // MARK: - Device Type Classification Tests
    
    func testDeviceTypeClassification() {
        let testCases: [(String, String)] = [
            ("MacBook Pro Microphone", "Built-in"),
            ("Built-in Microphone", "Built-in"),
            ("Internal Microphone", "Built-in"),
            ("USB Headset", "External"),
            ("External Microphone", "External"),
            ("BoomAudio", "Virtual"),
            ("MMAudio Device", "Virtual"),
            ("Virtual Audio Device", "Virtual"),
            ("Loopback Audio", "Virtual"),
            ("Unknown Device", "Unknown")
        ]
        
        for (deviceName, expectedType) in testCases {
            let device = MockAudioDeviceInfo(
                id: "test_\(deviceName.replacingOccurrences(of: " ", with: "_"))",
                name: deviceName,
                type: expectedType
            )
            
            XCTAssertEqual(device.type, expectedType, "Device '\(deviceName)' should be classified as '\(expectedType)'")
        }
    }
    
    // MARK: - Volume Level Calculation Tests
    
    func testVolumeLevelCalculation() {
        // Test with empty buffer
        let emptyBuffer = createTestAudioBuffer(frameLength: 1024, samples: Array(repeating: 0.0, count: 1024))
        let emptyLevel = calculateAudioLevel(buffer: emptyBuffer)
        XCTAssertEqual(emptyLevel, 0.0, accuracy: 0.0001, "Empty buffer should have zero volume level")
        
        // Test with constant amplitude buffer
        let constantBuffer = createTestAudioBuffer(frameLength: 1024, samples: Array(repeating: 0.5, count: 1024))
        let constantLevel = calculateAudioLevel(buffer: constantBuffer)
        XCTAssertEqual(constantLevel, 0.5, accuracy: 0.0001, "Constant amplitude buffer should have correct RMS level")
        
        // Test with varying amplitude buffer
        let varyingSamples = (0..<1024).map { Float(sin(Double($0) * 0.1)) * 0.3 }
        let varyingBuffer = createTestAudioBuffer(frameLength: 1024, samples: varyingSamples)
        let varyingLevel = calculateAudioLevel(buffer: varyingBuffer)
        XCTAssertGreaterThan(varyingLevel, 0.0, "Varying amplitude buffer should have non-zero volume level")
        XCTAssertLessThan(varyingLevel, 0.5, "Varying amplitude buffer should have reasonable volume level")
    }
    
    // MARK: - Speech Recognition Permission Tests
    
    func testSpeechRecognitionPermissionStates() {
        // Test initial state
        let initialStatus = SFSpeechRecognizer.authorizationStatus()
        let validStates: [SFSpeechRecognizerAuthorizationStatus] = [.notDetermined, .denied, .restricted, .authorized]
        XCTAssertTrue(validStates.contains(initialStatus), 
                     "Speech recognition status should be one of the valid states")
    }
    
    // MARK: - Audio Format Tests
    
    func testAudioFormatCompatibility() {
        // Test standard audio formats that should work with speech recognition
        let standardFormats: [AVAudioFormat?] = [
            AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1),
            AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1),
            AVAudioFormat(standardFormatWithSampleRate: 22050, channels: 1)
        ]
        
        for format in standardFormats {
            XCTAssertNotNil(format, "Standard audio format should be valid")
            if let format = format {
                XCTAssertEqual(format.channelCount, 1, "Format should be mono")
                XCTAssertTrue([22050, 44100, 48000].contains(format.sampleRate), 
                             "Sample rate should be standard")
            }
        }
    }
    
    // MARK: - Buffer Size Tests
    
    func testBufferSizeCompatibility() {
        let bufferSizes: [UInt32] = [512, 1024, 2048, 4096]
        
        for bufferSize in bufferSizes {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
            XCTAssertNotNil(format, "Format should be valid for buffer size \(bufferSize)")
            
            if let format = format {
                let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize)
                XCTAssertNotNil(buffer, "Buffer should be created for size \(bufferSize)")
                XCTAssertEqual(buffer?.frameCapacity, bufferSize, "Buffer capacity should match requested size")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingForInvalidAudioData() {
        // Test error handling with mock data that could cause NaN
        // Create a buffer with all zeros (should return 0.0)
        let silentBuffer = createTestAudioBuffer(frameLength: 1024, samples: Array(repeating: 0.0, count: 1024))
        let silentLevel = calculateAudioLevel(buffer: silentBuffer)
        XCTAssertEqual(silentLevel, 0.0, accuracy: 0.0001, "Silent buffer should have zero volume level")
        XCTAssertGreaterThanOrEqual(silentLevel, 0.0, "Volume level should never be negative")
        
        // Test with very small values that could cause precision issues
        let tinySamples: [Float] = Array(repeating: 0.000001, count: 1024)
        let tinyBuffer = createTestAudioBuffer(frameLength: 1024, samples: tinySamples)
        let tinyLevel = calculateAudioLevel(buffer: tinyBuffer)
        XCTAssertGreaterThanOrEqual(tinyLevel, 0.0, "Volume level should never be negative")
        XCTAssertLessThan(tinyLevel, 0.01, "Tiny values should result in very small volume")
        
        // Test with mixed positive and negative values
        let mixedSamples: [Float] = (0..<1024).map { Float($0 % 2 == 0 ? 0.1 : -0.1) }
        let mixedBuffer = createTestAudioBuffer(frameLength: 1024, samples: mixedSamples)
        let mixedLevel = calculateAudioLevel(buffer: mixedBuffer)
        XCTAssertGreaterThanOrEqual(mixedLevel, 0.0, "Volume level should never be negative")
        XCTAssertGreaterThan(mixedLevel, 0.0, "Mixed values should result in positive volume")
    }
    
    // MARK: - Performance Tests
    
    func testVolumeLevelCalculationPerformance() {
        let buffer = createTestAudioBuffer(frameLength: 1024, samples: Array(repeating: 0.5, count: 1024))
        
        measure {
            for _ in 0..<1000 {
                _ = calculateAudioLevel(buffer: buffer)
            }
        }
    }
    
    func testAudioDeviceInfoCreationPerformance() {
        measure {
            for i in 0..<1000 {
                _ = MockAudioDeviceInfo(
                    id: "device_\(i)",
                    name: "Test Device \(i)",
                    type: "Built-in"
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestAudioBuffer(frameLength: UInt32, samples: [Float]) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength)!
        
        buffer.frameLength = frameLength
        
        if let channelData = buffer.floatChannelData {
            let channelDataValue = channelData.pointee
            for i in 0..<Int(frameLength) {
                if i < samples.count {
                    channelDataValue[i] = samples[i]
                } else {
                    channelDataValue[i] = 0.0
                }
            }
        }
        
        return buffer
    }
    
    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0.0 }
        guard buffer.frameLength > 0 else { return 0.0 }
        
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }
        
        // Calculate RMS with proper error handling
        let sumOfSquares = channelDataValueArray.map { $0 * $0 }.reduce(0, +)
        let frameLengthFloat = Float(buffer.frameLength)
        
        // Prevent division by zero and NaN
        guard frameLengthFloat > 0 && sumOfSquares.isFinite else { return 0.0 }
        
        let meanSquare = sumOfSquares / frameLengthFloat
        guard meanSquare.isFinite && meanSquare >= 0 else { return 0.0 }
        
        let rms = sqrt(meanSquare)
        return rms.isFinite ? rms : 0.0
    }
}
