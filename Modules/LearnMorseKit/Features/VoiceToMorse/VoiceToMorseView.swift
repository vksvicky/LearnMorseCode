import SwiftUI
import Speech
import AVFoundation
import MorseCore

struct AudioDeviceInfo: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let type: String
    
    static func == (lhs: AudioDeviceInfo, rhs: AudioDeviceInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct VoiceToMorseView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    @State private var recognizedText = ""
    @State private var morseOutput = ""
    @State private var isRecording = false
    @State private var showingPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var speechRecognitionPermissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    #if os(iOS)
    @State private var microphonePermissionStatus: AVAudioSession.RecordPermission = .undetermined
    #else
    @State private var microphonePermissionGranted: Bool = false
    #endif
    @State private var speechRecognizer: SFSpeechRecognizer?
    @State private var audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var availableAudioInputs: [AudioDeviceInfo] = []
    @State private var selectedAudioInput: AudioDeviceInfo?
    @State private var currentVolumeLevel: Float = 0.0
    @State private var maxVolumeLevel: Float = 0.0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 30) {
                    if speechRecognitionPermissionStatus == .authorized && isMicrophonePermissionGranted {
                        mainInterface
                    } else {
                        permissionRequestInterface
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            checkPermissions()
            loadAvailableAudioInputs()
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionMessage)
        }
    }
    
    private var mainInterface: some View {
        VStack(spacing: 20) {
            // Audio Device Selection
            VStack(spacing: 12) {
                HStack {
                    Text("Audio Input Device:")
                        .font(.headline)
                    Spacer()
                }
                
                Picker("Select Audio Device", selection: $selectedAudioInput) {
                    ForEach(availableAudioInputs) { input in
                        Text("\(input.name) (\(input.type))")
                            .tag(input as AudioDeviceInfo?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedAudioInput) { _, newValue in
                    if let newValue = newValue {
                        selectAudioInput(newValue)
                    }
                }
                
                // Volume Level Display
                VStack(spacing: 8) {
                    HStack {
                        Text("Volume Level:")
                            .font(.subheadline)
                        Spacer()
                        Text("\(String(format: "%.1f", currentVolumeLevel * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("0%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(currentVolumeLevel > 0.1 ? Color.green : Color.orange)
                                    .frame(width: geometry.size.width * CGFloat(currentVolumeLevel), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        Text("100%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if maxVolumeLevel > 0 {
                        HStack {
                            Text("Peak: \(String(format: "%.1f", maxVolumeLevel * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: isRecording ? "mic.fill" : "mic.slash.fill")
                        .foregroundColor(isRecording ? .red : .gray)
                        .font(.title2)
                    
                    Text(isRecording ? "Listening..." : "Tap to start recording")
                        .font(.headline)
                        .foregroundColor(isRecording ? .red : .primary)
                }
                
                if !recognizedText.isEmpty {
                    Text("Recognized: \(recognizedText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
            
            HStack(spacing: 20) {
                Button(action: toggleRecording) {
                    HStack {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        Text(isRecording ? "Stop" : "Start Recording")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!isSpeechRecognitionAvailable)
                
                Button("Clear") {
                    recognizedText = ""
                    morseOutput = ""
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Morse Code Output")
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 12) {
                        Button("Play") {
                            morseModel.playMorseCode(morseOutput)
                        }
                        .foregroundColor(.green)
                        .disabled(morseOutput.isEmpty)
                        
                        Button("Copy") {
                            copyToClipboard(morseOutput)
                        }
                        .foregroundColor(.blue)
                        .disabled(morseOutput.isEmpty)
                    }
                }
                
                ScrollView {
                    Text(morseOutput.isEmpty ? "Start speaking to see Morse code..." : morseOutput)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(10)
                }
                .frame(minHeight: 120)
            }
            
            Spacer()
        }
    }
    
    private var permissionRequestInterface: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "mic.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Microphone Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This feature requires microphone access to convert your voice to Morse code. Please grant permission to continue.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button("Grant Permission") {
                    requestPermissions()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Open Settings") {
                    openSettings()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
    }
    
    private var isSpeechRecognitionAvailable: Bool {
        speechRecognizer?.isAvailable ?? false
    }
    
    private var isMicrophonePermissionGranted: Bool {
        #if os(iOS)
        return microphonePermissionStatus == .granted
        #else
        return microphonePermissionGranted
        #endif
    }
    
    private func checkPermissions() {
        speechRecognitionPermissionStatus = SFSpeechRecognizer.authorizationStatus()
        
        #if os(macOS)
        checkMicrophonePermissionOnMacOS()
        #else
        microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
        #endif
        
        if speechRecognitionPermissionStatus == .authorized {
            speechRecognizer = SFSpeechRecognizer()
        }
    }
    
    private func loadAvailableAudioInputs() {
        #if os(macOS)
        // On macOS, dynamically retrieve actual audio devices from the system
        var devices: [AudioDeviceInfo] = []
        
        // Get the default input device
        var defaultDeviceID: AudioDeviceID = 0
        var defaultDeviceSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var defaultDeviceProperty = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let defaultDeviceStatus = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultDeviceProperty,
            0,
            nil,
            &defaultDeviceSize,
            &defaultDeviceID
        )
        
        if defaultDeviceStatus == noErr {
            // Get device name
            var deviceName: Unmanaged<CFString>? = nil
            var deviceNameSize = UInt32(MemoryLayout<Unmanaged<CFString>>.size)
            var deviceNameProperty = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceNameCFString,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            let deviceNameStatus = AudioObjectGetPropertyData(
                defaultDeviceID,
                &deviceNameProperty,
                0,
                nil,
                &deviceNameSize,
                &deviceName
            )
            
            if deviceNameStatus == noErr, let name = deviceName {
                devices.append(AudioDeviceInfo(
                    id: "\(defaultDeviceID)",
                    name: name.takeRetainedValue() as String,
                    type: "Default"
                ))
            }
        }
        
        // Get all available audio devices
        var deviceListSize: UInt32 = 0
        var deviceListProperty = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let deviceListStatus = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &deviceListProperty,
            0,
            nil,
            &deviceListSize
        )
        
        if deviceListStatus == noErr {
            let deviceCount = Int(deviceListSize) / MemoryLayout<AudioDeviceID>.size
            var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
            
            let getDeviceListStatus = AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &deviceListProperty,
                0,
                nil,
                &deviceListSize,
                &deviceIDs
            )
            
            if getDeviceListStatus == noErr {
                for deviceID in deviceIDs {
                    // Check if this device has input channels
                    var inputChannels: UInt32 = 0
                    var inputChannelsSize = UInt32(MemoryLayout<UInt32>.size)
                    var inputChannelsProperty = AudioObjectPropertyAddress(
                        mSelector: kAudioDevicePropertyStreamConfiguration,
                        mScope: kAudioDevicePropertyScopeInput,
                        mElement: kAudioObjectPropertyElementMain
                    )
                    
                    let inputChannelsStatus = AudioObjectGetPropertyData(
                        deviceID,
                        &inputChannelsProperty,
                        0,
                        nil,
                        &inputChannelsSize,
                        &inputChannels
                    )
                    
                    if inputChannelsStatus == noErr && inputChannels > 0 {
                        // Get device name
                        var deviceName: Unmanaged<CFString>? = nil
                        var deviceNameSize = UInt32(MemoryLayout<Unmanaged<CFString>>.size)
                        var deviceNameProperty = AudioObjectPropertyAddress(
                            mSelector: kAudioDevicePropertyDeviceNameCFString,
                            mScope: kAudioObjectPropertyScopeGlobal,
                            mElement: kAudioObjectPropertyElementMain
                        )
                        
                        let deviceNameStatus = AudioObjectGetPropertyData(
                            deviceID,
                            &deviceNameProperty,
                            0,
                            nil,
                            &deviceNameSize,
                            &deviceName
                        )
                        
                        if deviceNameStatus == noErr, let name = deviceName {
                            // Determine device type based on name
                            var deviceType = "Unknown"
                            let deviceNameStr = name.takeRetainedValue() as String
                            if deviceNameStr.contains("MacBook") || deviceNameStr.contains("Built-in") || deviceNameStr.contains("Internal") {
                                deviceType = "Built-in"
                            } else if deviceNameStr.contains("USB") || deviceNameStr.contains("External") || deviceNameStr.contains("Headset") {
                                deviceType = "External"
                            } else if deviceNameStr.contains("Virtual") || deviceNameStr.contains("Boom") || deviceNameStr.contains("MMAudio") || deviceNameStr.contains("Loopback") {
                                deviceType = "Virtual"
                            }
                            
                            // Only add if not already added (avoid duplicates)
                            if !devices.contains(where: { $0.name == deviceNameStr }) {
                                devices.append(AudioDeviceInfo(
                                    id: "\(deviceID)",
                                    name: deviceNameStr,
                                    type: deviceType
                                ))
                            }
                        }
                    }
                }
            }
        }
        
        // Fallback to generic list if we couldn't get real devices
        if devices.isEmpty {
            devices.append(AudioDeviceInfo(
                id: "default",
                name: "Default Input Device",
                type: "System Default"
            ))
        }
        
        availableAudioInputs = devices
        
        // Select the first available input by default
        if selectedAudioInput == nil && !availableAudioInputs.isEmpty {
            selectedAudioInput = availableAudioInputs.first
        }
        
        print("🔍 Loaded \(availableAudioInputs.count) real audio inputs from system:")
        for (index, input) in availableAudioInputs.enumerated() {
            print("   \(index): \(input.name) - \(input.type)")
        }
        #else
        // iOS implementation using AVAudioSession
        let audioSession = AVAudioSession.sharedInstance()
        let inputs = audioSession.availableInputs ?? []
        
        availableAudioInputs = inputs.map { input in
            AudioDeviceInfo(
                id: input.uid,
                name: input.portName,
                type: input.portType.rawValue
            )
        }
        
        if selectedAudioInput == nil && !availableAudioInputs.isEmpty {
            selectedAudioInput = availableAudioInputs.first
        }
        #endif
    }
    
    private func selectAudioInput(_ input: AudioDeviceInfo) {
        #if os(macOS)
        print("🎤 Selected audio input: \(input.name) - \(input.type)")
        // On macOS, we'll just log the selection for now
        // The actual device selection will be handled by the system
        #else
        // iOS implementation
        let audioSession = AVAudioSession.sharedInstance()
        if let portDescription = audioSession.availableInputs?.first(where: { $0.uid == input.id }) {
            do {
                try audioSession.setPreferredInput(portDescription)
                print("🎤 Selected audio input: \(input.name) - \(input.type)")
            } catch {
                print("❌ Failed to set preferred input: \(error)")
            }
        }
        #endif
    }
    
    #if os(macOS)
    private func checkMicrophonePermissionOnMacOS() {
        microphonePermissionGranted = false
    }
    #endif
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.speechRecognitionPermissionStatus = authStatus
                
                switch authStatus {
                case .authorized:
                    self.speechRecognizer = SFSpeechRecognizer()
                case .denied, .restricted, .notDetermined:
                    self.permissionMessage = "Speech recognition permission is required to use this feature. Please enable it in Settings."
                    self.showingPermissionAlert = true
                @unknown default:
                    break
                }
            }
        }
        
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.microphonePermissionStatus = granted ? .granted : .denied
            }
        }
        #else
        requestMicrophonePermissionOnMacOS()
        #endif
    }
    
    #if os(macOS)
    private func requestMicrophonePermissionOnMacOS() {
        print("🎤 Requesting microphone permission on macOS...")
        let permissionAudioEngine = AVAudioEngine()
        let inputNode = permissionAudioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        print("🔍 Permission check - Input node format: \(recordingFormat)")
        print("🔍 Permission check - Input node available: \(inputNode.numberOfInputs > 0)")
        
        do {
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                let level = self.calculateAudioLevel(buffer: buffer)
                if level > 0.0001 {
                    print("🎤 Permission test - Audio detected: \(String(format: "%.6f", level))")
                }
            }
            permissionAudioEngine.prepare()
            try permissionAudioEngine.start()
            
            print("✅ Permission test - Audio engine started successfully")
            DispatchQueue.main.async {
                self.microphonePermissionGranted = true
            }
            
            // Let it run for a moment to test
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                permissionAudioEngine.stop()
                inputNode.removeTap(onBus: 0)
                print("🛑 Permission test - Audio engine stopped")
            }
            
        } catch {
            print("❌ Microphone permission denied: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.microphonePermissionGranted = false
                self.permissionMessage = "Microphone access denied. Please grant microphone permission in Settings."
                self.showingPermissionAlert = true
            }
        }
    }
    #endif
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        print("🎤 Starting recording...")
        print("🔍 Speech recognizer available: \(speechRecognizer?.isAvailable ?? false)")
        print("🔍 Speech recognition status: \(speechRecognitionPermissionStatus)")
        print("🔍 Microphone permission granted: \(microphonePermissionGranted)")
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ Speech recognizer not available")
            permissionMessage = "Speech recognition is not available."
            showingPermissionAlert = true
            return
        }
        
        // Clean shutdown of any existing recording
        stopRecording()
        
        // Wait a moment for cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
             // Create new audio engine
             self.audioEngine = AVAudioEngine()
             
             // Force the audio engine to use the system's default input device
             print("🔍 Audio engine input node: \(self.audioEngine.inputNode)")
             print("🔍 Input node number of inputs: \(self.audioEngine.inputNode.numberOfInputs)")
             
             // Configure audio session for speech
             #if os(iOS)
             do {
                 let audioSession = AVAudioSession.sharedInstance()
                 try audioSession.setCategory(.record, mode: .spokenAudio, options: [])
                 try audioSession.setActive(true)
                 print("✅ Audio session configured")
             } catch {
                 print("❌ Audio session error: \(error)")
                 self.permissionMessage = "Audio setup failed: \(error.localizedDescription)"
                 self.showingPermissionAlert = true
                 return
             }
             #endif
            
            // Create recognition request
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = false
            request.taskHint = .dictation
            self.recognitionRequest = request
            
             // Get input node - use its native format
             let inputNode = self.audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
             print("📊 Format: \(recordingFormat.sampleRate)Hz, \(recordingFormat.channelCount)ch")
             print("🔍 Input node available: \(inputNode.numberOfInputs > 0)")
             print("🔍 Input node format: \(recordingFormat)")
             
             // Check available audio devices (macOS)
             #if os(macOS)
             print("🔍 Available input devices:")
             print("   - Input node: \(inputNode)")
             print("   - Number of inputs: \(inputNode.numberOfInputs)")
             for i in 0..<inputNode.numberOfInputs {
                 let format = inputNode.outputFormat(forBus: i)
                 print("   - Bus \(i): \(format)")
             }
             #endif
             
             // Audio device selection is now handled by the UI dropdown
             print("🎤 Using selected audio device: \(selectedAudioInput?.name ?? "Default")")
            
            // Install tap with native format and standard buffer
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
                request.append(buffer)
                
                // Monitor audio levels - lower threshold to catch more audio
                let level = self.calculateAudioLevel(buffer: buffer)
                
                // Log every buffer for debugging
                print("📊 Buffer: \(buffer.frameLength) frames, level: \(String(format: "%.6f", level))")
                
                if level > 0.0001 { // Much lower threshold
                    print("🎙️ Audio detected: \(String(format: "%.6f", level))")
                } else {
                    print("🔍 No audio detected (level: \(String(format: "%.6f", level)))")
                }
                
                // Check if buffer has any non-zero samples
                if let channelData = buffer.floatChannelData {
                    let channelDataValue = channelData.pointee
                    let hasNonZeroSamples = (0..<Int(buffer.frameLength)).contains { channelDataValue[$0] != 0.0 }
                    if hasNonZeroSamples {
                        print("🎙️ Non-zero samples detected!")
                    }
                    
                    // Log first few samples to see what we're getting
                    if Int(time.sampleTime) % 44100 == 0 { // Every second
                        let firstSamples = (0..<min(10, Int(buffer.frameLength))).map { channelDataValue[$0] }
                        print("🔍 First 10 samples: \(firstSamples)")
                    }
                }
            }
            
             // Start recognition task
             print("🎯 Starting speech recognition task...")
             self.recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                 print("🎯 Recognition callback fired")
                 DispatchQueue.main.async {
                     guard self.isRecording else { 
                         print("⚠️ Not recording, ignoring callback")
                         return 
                     }
                     
                     if let result = result {
                         let text = result.bestTranscription.formattedString
                         print("✅ Speech result: '\(text)' (final: \(result.isFinal))")
                         print("   Confidence: \(result.bestTranscription.segments.map { $0.confidence }.reduce(0, +) / Float(result.bestTranscription.segments.count))")
                         self.recognizedText = text
                         self.convertToMorse()
                         
                         if result.isFinal {
                             print("🔄 Final result, restarting in 0.5s...")
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                 if self.isRecording {
                                     self.restartRecognition()
                                 }
                             }
                         }
                     }
                     
                     if let error = error {
                         let code = (error as NSError).code
                         print("⚠️ Recognition error \(code): \(error.localizedDescription)")
                         print("   Error details: \(error)")
                         
                         if code == 1110 {
                             print("⏰ No speech detected - restarting in 1s...")
                             DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                 if self.isRecording {
                                     self.restartRecognition()
                                 }
                             }
                         } else if code != 216 {
                             print("🛑 Fatal error, stopping recording")
                             self.stopRecording()
                         }
                     }
                 }
             }
             print("🎯 Recognition task created and started")
            
             // Start audio engine
             self.audioEngine.prepare()
             do {
                 try self.audioEngine.start()
                 print("✅ Engine started - SPEAK NOW!")
                 self.isRecording = true
                 
                 // Reset volume levels
                 self.currentVolumeLevel = 0.0
                 self.maxVolumeLevel = 0.0
                 
                 // Test microphone access after a short delay
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                     print("🔍 Testing microphone access with separate engine...")
                     let testEngine = AVAudioEngine()
                     let testInputNode = testEngine.inputNode
                     let testFormat = testInputNode.outputFormat(forBus: 0)
                     
                     print("🔍 Test engine input node: \(testInputNode)")
                     print("🔍 Test engine format: \(testFormat)")
                     
                     do {
                         testInputNode.installTap(onBus: 0, bufferSize: 1024, format: testFormat) { buffer, _ in
                             let level = self.calculateAudioLevel(buffer: buffer)
                             print("🔍 Test engine buffer: \(buffer.frameLength) frames, level: \(String(format: "%.6f", level))")
                             if level > 0.0001 {
                                 print("🎙️ Test engine detected audio: \(String(format: "%.6f", level))")
                             }
                         }
                         testEngine.prepare()
                         try testEngine.start()
                         print("✅ Test engine started successfully")
                         
                         // Test with different buffer sizes
                         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                             print("🔍 Testing with different buffer size...")
                             testInputNode.removeTap(onBus: 0)
                             testInputNode.installTap(onBus: 0, bufferSize: 512, format: testFormat) { buffer, _ in
                                 let level = self.calculateAudioLevel(buffer: buffer)
                                 print("🔍 Small buffer: \(buffer.frameLength) frames, level: \(String(format: "%.6f", level))")
                                 if level > 0.0001 {
                                     print("🎙️ Small buffer detected audio: \(String(format: "%.6f", level))")
                                 }
                             }
                         }
                         
                         DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                             testEngine.stop()
                             testInputNode.removeTap(onBus: 0)
                             print("🛑 Test engine stopped")
                         }
                     } catch {
                         print("❌ Test engine error: \(error)")
                     }
                 }
             } catch {
                 print("❌ Engine error: \(error)")
                 self.permissionMessage = "Microphone failed: \(error.localizedDescription)"
                 self.showingPermissionAlert = true
                 self.recognitionTask?.cancel()
             }
        }
    }
    
    private func restartRecognition() {
        guard isRecording, let speechRecognizer = speechRecognizer else { return }
        
        print("🔄 Restarting recognition...")
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        request.taskHint = .dictation
        recognitionRequest = request
        
        audioEngine.inputNode.removeTap(onBus: 0)
        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
            
            let level = self.calculateAudioLevel(buffer: buffer)
            if level > 0.001 {
                print("🎙️ Audio: \(String(format: "%.4f", level))")
            }
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                guard self.isRecording else { return }
                
                if let result = result {
                    print("✅ '\(result.bestTranscription.formattedString)'")
                    self.recognizedText = result.bestTranscription.formattedString
                    self.convertToMorse()
                    
                    if result.isFinal {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.isRecording {
                                self.restartRecognition()
                            }
                        }
                    }
                }
                
                if let error = error {
                    let code = (error as NSError).code
                    if code == 1110 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if self.isRecording {
                                self.restartRecognition()
                            }
                        }
                    } else if code != 216 {
                    self.stopRecording()
                    }
                }
            }
        }
    }
    
    private func stopRecording() {
        print("🛑 Stopping recording")
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error)")
        }
        #endif
    }
    
    private func convertToMorse() {
        guard !recognizedText.isEmpty else {
            morseOutput = ""
            return
        }
        
        do {
            morseOutput = try MorseEncoder().encode(recognizedText)
        } catch {
            print("Failed to encode: \(error)")
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
    
    private func openSettings() {
        #if os(macOS)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
        #else
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        #endif
    }
    
    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { 
            print("❌ No channel data available")
            return 0.0 
        }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        
        // Debug: Log the calculation details
        if Int.random(in: 1...100) == 1 { // Log 1% of the time to avoid spam
            let maxSample = channelDataValueArray.map { abs($0) }.max() ?? 0.0
            let minSample = channelDataValueArray.map { abs($0) }.min() ?? 0.0
            print("🔍 Audio calculation: max=\(String(format: "%.6f", maxSample)), min=\(String(format: "%.6f", minSample)), rms=\(String(format: "%.6f", rms))")
        }
        
        // Update volume display on main thread
        DispatchQueue.main.async {
            self.currentVolumeLevel = rms
            if rms > self.maxVolumeLevel {
                self.maxVolumeLevel = rms
            }
        }
        
        return rms
    }
}