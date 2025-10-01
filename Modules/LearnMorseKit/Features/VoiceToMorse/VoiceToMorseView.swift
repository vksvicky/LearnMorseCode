import SwiftUI
import Speech
import AVFoundation
import MorseCore

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
    @State private var audioEngineStarted = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 30) {
                    if speechRecognitionPermissionStatus == .authorized && isMicrophonePermissionGranted {
                        // Main interface when permissions are granted
                        mainInterface
                    } else {
                        // Permission request interface
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
            // Status section
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
            
            // Control buttons
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
            
            // Output section
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
        // Check speech recognition permission
        speechRecognitionPermissionStatus = SFSpeechRecognizer.authorizationStatus()
        
        // Check microphone permission
        #if os(macOS)
        // On macOS, we'll assume microphone permission is granted for now
        // and handle errors during recording setup
        microphonePermissionGranted = true
        #else
        microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
        #endif
        
        // Initialize speech recognizer only if we have permission
        if speechRecognitionPermissionStatus == .authorized {
            speechRecognizer = SFSpeechRecognizer()
        }
    }
    
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
        
        // Request microphone permission on iOS
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.microphonePermissionStatus = granted ? .granted : .denied
            }
        }
        #else
        // On macOS, we'll handle microphone permission errors during recording
        microphonePermissionGranted = true
        #endif
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            permissionMessage = "Speech recognition is not available. Please check your permissions."
            showingPermissionAlert = true
            return
        }
        
        let newRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        newRecognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            newRecognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.recognitionRequest = newRecognitionRequest
            }
        } catch {
            print("Audio engine start error: \(error)")
            permissionMessage = "Microphone access denied. Please grant microphone permission in Settings."
            showingPermissionAlert = true
            return
        }
        
        let newRecognitionTask = speechRecognizer.recognitionTask(with: newRecognitionRequest) { result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.convertToMorse()
                }
                
                if let error = error {
                    print("Recognition error: \(error)")
                    self.stopRecording()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.recognitionTask = newRecognitionTask
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        DispatchQueue.main.async {
            self.recognitionRequest = nil
            self.recognitionTask = nil
            self.isRecording = false
        }
    }
    
    private func convertToMorse() {
        guard !recognizedText.isEmpty else {
            morseOutput = ""
            return
        }
        
        do {
            morseOutput = try MorseEncoder().encode(recognizedText)
        } catch {
            print("Failed to encode text: \(error)")
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
}
