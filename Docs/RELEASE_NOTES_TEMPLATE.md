# LearnMorseCode v{VERSION} Release Notes

## 🎉 What's New

### Features
- **Interactive Morse Code Learning**: Convert text to Morse code and vice versa with real-time audio playback
- **Voice to Morse Conversion**: Convert speech to Morse code using advanced speech recognition
- **Visual Feedback**: See highlighted characters during audio playback for better learning
- **Game Mode**: Practice with interactive games and track your progress
- **Reference Guide**: Complete Morse code character set with audio examples

### Technical Improvements
- **Universal Binary**: Runs natively on both Intel and Apple Silicon Macs
- **Optimized Performance**: Faster audio processing and visual feedback
- **Modern UI**: Built with SwiftUI for a native macOS experience
- **Comprehensive Testing**: 137 unit tests with 100% pass rate

## 📦 Distribution Packages

### Universal Binary (Recommended)
- **File**: `LearnMorseCode-Universal-v{VERSION}.dmg`
- **Compatibility**: Intel Macs (2012+) and Apple Silicon Macs (2020+)
- **Size**: ~{UNIVERSAL_SIZE}
- **Use Case**: Works on all supported Macs

### Apple Silicon Only
- **File**: `LearnMorseCode-Silicon-v{VERSION}.dmg`
- **Compatibility**: Apple Silicon Macs only (2020+)
- **Size**: ~{SILICON_SIZE}
- **Use Case**: Optimized for M1/M2/M3 Macs

### ZIP Packages
- **Universal**: `LearnMorseCode-Universal-v{VERSION}.zip`
- **Silicon**: `LearnMorseCode-Silicon-v{VERSION}.zip`
- **Use Case**: Alternative installation method or for developers

## 🔧 System Requirements

- **macOS**: 13.0 (Ventura) or later
- **Architecture**: Intel x64 or Apple Silicon (ARM64)
- **Memory**: 4GB RAM minimum, 8GB recommended
- **Storage**: 50MB available space
- **Audio**: Built-in or external microphone for Voice to Morse feature

## 🚀 Installation

1. **Download** the appropriate package for your Mac:
   - Intel Macs: Use Universal package
   - Apple Silicon Macs: Use either Universal or Silicon package
2. **Open** the DMG file
3. **Drag** LearnMorseCode.app to your Applications folder
4. **Launch** from Applications or Spotlight

## 🔐 Permissions

The app requires the following permissions:
- **Microphone**: For Voice to Morse conversion
- **Speech Recognition**: For converting speech to text

### Granting Permissions
1. Launch the app
2. Go to **Voice → Morse** tab
3. Click **"Grant Permissions"** when prompted
4. Allow access in System Settings

If the app doesn't appear in System Settings, see the troubleshooting section below.

## 🐛 Troubleshooting

### App Won't Launch
- **Check macOS version**: Requires macOS 13.0 or later
- **Check architecture**: Ensure you downloaded the correct package
- **Try ZIP installation**: Extract the ZIP file and run the app directly

### Voice to Morse Not Working
- **Check permissions**: Go to System Settings → Privacy & Security → Microphone
- **Grant speech recognition**: System Settings → Privacy & Security → Speech Recognition
- **Test microphone**: Try with other apps like QuickTime or FaceTime

### App Not in System Settings
- **Code signing issue**: The app needs proper code signing to appear in System Settings
- **Solution**: Download from official source or build from source with proper signing
- **Alternative**: Use the app's built-in permission request dialogs

### Audio Issues
- **Check audio output**: Ensure speakers/headphones are working
- **Check volume**: Adjust system volume and app volume
- **Try different audio device**: Switch between built-in and external audio

### Performance Issues
- **Use Silicon package**: On Apple Silicon Macs, use the Silicon-specific package
- **Close other apps**: Free up system resources
- **Restart the app**: Close and relaunch if experiencing slowdowns

## 📞 Support

- **GitHub Issues**: Report bugs and request features
- **Documentation**: See README.md for detailed usage instructions
- **Source Code**: Available on GitHub for developers

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Build Information:**
- Version: {VERSION}
- Build: {BUILD_NUMBER}
- Built: {BUILD_DATE}
- Xcode: {XCODE_VERSION}
