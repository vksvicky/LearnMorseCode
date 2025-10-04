#!/bin/bash

# LearnMorseCode - Universal Build Script
# This script handles all build scenarios: debug, release, and distribution packages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="LearnMorseCode"
SCHEME_NAME="LearnMorseCode"
BUNDLE_ID="club.cycleruncode.LearnMorseCode"

# Function to generate automatic version numbers
generate_auto_version() {
    local current_date=$(date)
    local month=$(date +%m)
    local year=$(date +%Y)
    local day=$(date +%d)
    
    # Format: month.year
    local marketing_version="${month}.${year}"
    
    # Read current build from Info.plist
    local info_plist_path="LearnMorseCode/Info.plist"
    local current_build="1"
    
    if [[ -f "$info_plist_path" ]]; then
        local current_build_from_plist=$(plutil -extract CFBundleVersion raw "$info_plist_path" 2>/dev/null || echo "1")
        if [[ -n "$current_build_from_plist" && "$current_build_from_plist" =~ ^[0-9]+\.[0-9]+$ ]]; then
            # Extract day and build number from current build (format: day.build_number)
            local current_day_from_build=$(echo "$current_build_from_plist" | cut -d'.' -f1)
            local current_build_number=$(echo "$current_build_from_plist" | cut -d'.' -f2)
            
            if [[ "$current_day_from_build" == "$day" ]]; then
                # Same day, increment build number
                current_build="${day}.$((current_build_number + 1))"
            else
                # New day, reset to 1
                current_build="${day}.1"
            fi
        else
            # Invalid format, start fresh
            current_build="${day}.1"
        fi
    else
        # No Info.plist, start fresh
        current_build="${day}.1"
    fi
    
    echo "$marketing_version|$current_build"
}

# Function to read current version from Info.plist
read_current_version() {
    local info_plist_path="LearnMorseCode/Info.plist"
    
    if [[ -f "$info_plist_path" ]]; then
        local current_version=$(plutil -extract CFBundleShortVersionString raw "$info_plist_path" 2>/dev/null || echo "1.0.0")
        local current_build=$(plutil -extract CFBundleVersion raw "$info_plist_path" 2>/dev/null || echo "1")
        echo "$current_version|$current_build"
    else
        echo "1.0.0|1"
    fi
}

# Default version and build number (can be overridden via command line)
DEFAULT_VERSION="1.0.0"
DEFAULT_BUILD_NUMBER="1"

# Parse command line arguments for version and build number
VERSION="$DEFAULT_VERSION"
BUILD_NUMBER="$DEFAULT_BUILD_NUMBER"
AUTO_VERSION=false

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}🚀 LearnMorseCode Universal Build Script${NC}"
    echo "================================================"
    echo ""
    echo "Usage: $0 [OPTION] [--version VERSION] [--build BUILD_NUMBER] [--auto-version]"
    echo ""
    echo "Options:"
    echo "  debug       Build and run debug version (default) - auto-increments build number"
    echo "  release     Build and run release version - auto-increments build number"
    echo "  run         Build and run app - auto-increments build number"
    echo "  test        Run tests with coverage (uses current tested version)"
    echo "  packages    Build distribution packages (uses current tested version)"
    echo "  clean       Clean build artifacts"
    echo "  diagnose    Diagnose version information and running processes"
    echo "  help        Show this help message"
    echo ""
    echo "Version Options:"
    echo "  --version VERSION     Set version number (e.g., 10.2025)"
    echo "  --build BUILD_NUMBER  Set build number (e.g., 04.8)"
    echo "  --auto-version        Auto-generate version (month.year) and build (day.build_number)"
    echo ""
    echo "Auto-Increment Behavior:"
    echo "  • Development builds (debug/release/run): Auto-increments build number for current day"
    echo "  • Same day: Build number increments (e.g., 04.6 → 04.7 → 04.8)"
    echo "  • New day: Build number resets to day.1 (e.g., 04.8 → 05.1)"
    echo "  • Packages and test commands: Use current tested version (no auto-increment)"
    echo "  • Note: Version parameters (--version, --build, --auto-version) are ignored for packages and test commands"
    echo "  • Version format: month.year (e.g., 10.2025)"
    echo "  • Build format: day.build_number (e.g., 04.6)"
    echo ""
    echo "Package Types:"
    echo "  • Universal: Runs on both Intel and Apple Silicon Macs"
    echo "  • Silicon: Optimized for Apple Silicon Macs only"
    echo "  • Both types are built when using 'packages' command"
    echo ""
    echo "Examples:"
    echo "  $0                                          # Debug build and run (auto-increments build number)"
    echo "  $0 debug                                    # Debug build and run (auto-increments build number)"
    echo "  $0 release                                  # Release build and run (auto-increments build number)"
    echo "  $0 run                                      # Build and run app (auto-increments build number)"
    echo "  $0 test                                     # Run tests (uses current tested version)"
    echo "  $0 packages                                 # Build Universal + Silicon packages (uses current tested version)"
    echo "  $0 packages --version 10.2025               # Build packages (version parameters ignored - uses current tested version)"
    echo "  $0 packages --version 10.2025 --build 04.8  # Build packages (version parameters ignored - uses current tested version)"
    echo "  $0 packages --auto-version                  # Build packages (auto-version ignored - uses current tested version)"
    echo "  $0 clean                                    # Clean build artifacts"
    echo ""
    echo "Current Version: $VERSION (Build $BUILD_NUMBER)"
}

# Function to update Info.plist with version numbers
update_info_plist() {
    local version="$1"
    local build_number="$2"
    local info_plist_path="LearnMorseCode/Info.plist"
    
    if [[ ! -f "$info_plist_path" ]]; then
        print_error "Info.plist not found at $info_plist_path"
        exit 1
    fi
    
    print_status "Updating Info.plist with version $version (build $build_number)..."
    
    # Use plutil to update the Info.plist
    plutil -replace CFBundleShortVersionString -string "$version" "$info_plist_path"
    plutil -replace CFBundleVersion -string "$build_number" "$info_plist_path"
    
    print_success "Info.plist updated successfully"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild not found. Please install Xcode command line tools."
        exit 1
    fi
    
    if ! command -v swift &> /dev/null; then
        print_error "swift not found. Please install Xcode command line tools."
        exit 1
    fi
    
    if ! command -v plutil &> /dev/null; then
        print_error "plutil not found. Please install Xcode command line tools."
        exit 1
    fi
}

# Function to build debug version
build_debug() {
    print_status "Building debug version..."
    
    xcodebuild clean \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Debug
    
    if xcodebuild build \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Debug \
        -destination "platform=macOS" \
        MARKETING_VERSION="$VERSION" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGN_STYLE=Automatic \
        INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
        INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning."; then
        print_success "Debug build completed!"
    else
        print_error "Debug build failed!"
        exit 1
    fi
}

# Function to build release version
build_release() {
    print_status "Building release version..."
    
    xcodebuild clean \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Release
    
    xcodebuild build \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -destination "platform=macOS" \
        MARKETING_VERSION="$VERSION" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGN_STYLE=Automatic \
        INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
        INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning."
    
    print_success "Release build completed!"
}

# Function to build and run app (reads current version from Info.plist)
build_and_run() {
    print_status "Building and running app with current version from Info.plist..."
    
    # Kill any existing instances of the app to prevent conflicts
    print_status "Stopping any existing app instances..."
    pkill -f "LearnMorseCode" 2>/dev/null || true
    
    # Clean build to ensure fresh compilation
    print_status "Cleaning build artifacts..."
    xcodebuild clean \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Debug \
        -derivedDataPath ~/Library/Developer/Xcode/DerivedData/LearnMorseCode-gidpnppgzrnbkeavhfhqcwhxietw \
        >/dev/null 2>&1 || true
    
    # Build the app with version parameters
    print_status "Building app with version $VERSION (Build $BUILD_NUMBER)..."
    if xcodebuild build \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Debug \
        -derivedDataPath ~/Library/Developer/Xcode/DerivedData/LearnMorseCode-gidpnppgzrnbkeavhfhqcwhxietw \
        MARKETING_VERSION="$VERSION" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGN_STYLE=Automatic \
        INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
        INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning."; then
        
        # Verify the built app has the correct version
        local built_app_path="/Users/vivek/Library/Developer/Xcode/DerivedData/LearnMorseCode-gidpnppgzrnbkeavhfhqcwhxietw/Build/Products/Debug/$PROJECT_NAME.app"
        if [[ -d "$built_app_path" ]]; then
            local built_version=$(plutil -extract CFBundleShortVersionString raw "$built_app_path/Contents/Info.plist" 2>/dev/null || echo "unknown")
            local built_build=$(plutil -extract CFBundleVersion raw "$built_app_path/Contents/Info.plist" 2>/dev/null || echo "unknown")
            print_status "Built app version: $built_version (Build $built_build)"
            
            if [[ "$built_version" == "$VERSION" && "$built_build" == "$BUILD_NUMBER" ]]; then
                print_success "Version verification passed!"
            else
                print_error "Version mismatch! Expected: $VERSION ($BUILD_NUMBER), Got: $built_version ($built_build)"
                exit 1
            fi
        fi
        
        # Launch the app
        print_status "Launching app..."
        open "$built_app_path"
        print_success "App launched with version $VERSION (Build $BUILD_NUMBER)!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to run tests
run_tests() {
    print_status "Running tests with coverage..."
    
    cd Modules/LearnMorseKit
    swift test --enable-code-coverage
    cd ../..
    
    print_success "Tests completed!"
}

# Function to build distribution packages
build_packages() {
    print_status "Building distribution packages..."
    
    # Check if create-dmg is available
    if ! command -v create-dmg &> /dev/null; then
        print_warning "create-dmg not found. Installing via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install create-dmg
        else
            print_error "Homebrew not found. Please install create-dmg manually:"
            print_error "  brew install create-dmg"
            exit 1
        fi
    fi
    
    # Create packages directory
    PACKAGES_DIR="Packages"
    mkdir -p "$PACKAGES_DIR"
    
    # Clean previous builds
    print_status "Cleaning previous builds..."
    rm -rf "$PACKAGES_DIR"/*
    
    # Build Universal Binary
    print_status "Building Universal Binary..."
    xcodebuild clean \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Release
    
    xcodebuild archive \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -destination "generic/platform=macOS" \
        -archivePath "$PACKAGES_DIR/$PROJECT_NAME-Universal.xcarchive" \
        MARKETING_VERSION="$VERSION" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGN_STYLE=Automatic \
        INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
        INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning."
    
    # Build Apple Silicon Only
    print_status "Building Apple Silicon Binary..."
    xcodebuild archive \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -destination "platform=macOS,arch=arm64" \
        -archivePath "$PACKAGES_DIR/$PROJECT_NAME-Silicon.xcarchive" \
        MARKETING_VERSION="$VERSION" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGN_STYLE=Automatic \
        INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
        INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning."
    
    # Extract apps from archives to temporary location
    print_status "Extracting apps from archives..."
    TEMP_DIR="$PACKAGES_DIR/temp"
    mkdir -p "$TEMP_DIR"
    
    UNIVERSAL_APP="$TEMP_DIR/$PROJECT_NAME-Universal.app"
    SILICON_APP="$TEMP_DIR/$PROJECT_NAME-Silicon.app"
    
    cp -R "$PACKAGES_DIR/$PROJECT_NAME-Universal.xcarchive/Products/Applications/$PROJECT_NAME.app" "$UNIVERSAL_APP"
    cp -R "$PACKAGES_DIR/$PROJECT_NAME-Silicon.xcarchive/Products/Applications/$PROJECT_NAME.app" "$SILICON_APP"
    
    # Create release notes
    print_status "Creating release notes..."
    cat > "$PACKAGES_DIR/RELEASE_NOTES_v$VERSION.md" << EOF
# LearnMorseCode v$VERSION Release Notes

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
- **File**: \`$PROJECT_NAME-Universal-v$VERSION.dmg\`
- **Compatibility**: Intel Macs (2012+) and Apple Silicon Macs (2020+)
- **Use Case**: Works on all supported Macs

### Apple Silicon Only
- **File**: \`$PROJECT_NAME-Silicon-v$VERSION.dmg\`
- **Compatibility**: Apple Silicon Macs only (2020+)
- **Use Case**: Optimized for M1/M2/M3 Macs

### ZIP Packages
- **Universal**: \`$PROJECT_NAME-Universal-v$VERSION.zip\`
- **Silicon**: \`$PROJECT_NAME-Silicon-v$VERSION.zip\`
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
- Version: $VERSION
- Build: $BUILD_NUMBER
- Built: $(date)
- Xcode: $(xcodebuild -version | head -1)
EOF
    
    # Create ZIP packages with release notes and checksums
    print_status "Creating ZIP packages..."
    
    # Copy release notes to temp directory for clean ZIP structure
    cp "$PACKAGES_DIR/RELEASE_NOTES_v$VERSION.md" "$PACKAGES_DIR/temp/"
    
    cd "$PACKAGES_DIR/temp"
    
    # Universal ZIP (from temp directory to avoid temp folder in archive)
    zip -r "../$PROJECT_NAME-Universal-v$VERSION.zip" "$PROJECT_NAME-Universal.app" "RELEASE_NOTES_v$VERSION.md"
    
    # Silicon ZIP (from temp directory to avoid temp folder in archive)
    zip -r "../$PROJECT_NAME-Silicon-v$VERSION.zip" "$PROJECT_NAME-Silicon.app" "RELEASE_NOTES_v$VERSION.md"
    
    cd "../.."
    
    # Create DMG packages
    print_status "Creating DMG packages..."
    
    # Create DMG content directories
    UNIVERSAL_DMG_DIR="$PACKAGES_DIR/universal-dmg"
    SILICON_DMG_DIR="$PACKAGES_DIR/silicon-dmg"
    
    mkdir -p "$UNIVERSAL_DMG_DIR"
    mkdir -p "$SILICON_DMG_DIR"
    
    # Copy apps and release notes to DMG directories
    cp -R "$UNIVERSAL_APP" "$UNIVERSAL_DMG_DIR/"
    cp -R "$SILICON_APP" "$SILICON_DMG_DIR/"
    cp "$PACKAGES_DIR/RELEASE_NOTES_v$VERSION.md" "$UNIVERSAL_DMG_DIR/"
    cp "$PACKAGES_DIR/RELEASE_NOTES_v$VERSION.md" "$SILICON_DMG_DIR/"
    
    # Universal DMG
    create-dmg \
        --volname "$PROJECT_NAME v$VERSION (Universal)" \
        --volicon "LearnMorseCode/Assets.xcassets/AppIcon.appiconset/AppIcon-512.png" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "$PROJECT_NAME-Universal.app" 175 120 \
        --icon "RELEASE_NOTES_v$VERSION.md" 175 200 \
        --hide-extension "$PROJECT_NAME-Universal.app" \
        --app-drop-link 425 120 \
        --no-internet-enable \
        "$PACKAGES_DIR/$PROJECT_NAME-Universal-v$VERSION.dmg" \
        "$UNIVERSAL_DMG_DIR/"
    
    # Silicon DMG
    create-dmg \
        --volname "$PROJECT_NAME v$VERSION (Apple Silicon)" \
        --volicon "LearnMorseCode/Assets.xcassets/AppIcon.appiconset/AppIcon-512.png" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "$PROJECT_NAME-Silicon.app" 175 120 \
        --icon "RELEASE_NOTES_v$VERSION.md" 175 200 \
        --hide-extension "$PROJECT_NAME-Silicon.app" \
        --app-drop-link 425 120 \
        --no-internet-enable \
        "$PACKAGES_DIR/$PROJECT_NAME-Silicon-v$VERSION.dmg" \
        "$SILICON_DMG_DIR/"
    
    # Generate checksums
    print_status "Generating checksums..."
    cd "$PACKAGES_DIR"
    shasum -a 256 *.dmg *.zip > "CHECKSUMS_v$VERSION.txt"
    cd ".."
    
    # Clean up temporary files and archives
    print_status "Cleaning up temporary files..."
    rm -rf "$PACKAGES_DIR/temp"
    rm -rf "$PACKAGES_DIR/universal-dmg"
    rm -rf "$PACKAGES_DIR/silicon-dmg"
    rm -rf "$PACKAGES_DIR/$PROJECT_NAME-Universal.xcarchive"
    rm -rf "$PACKAGES_DIR/$PROJECT_NAME-Silicon.xcarchive"
    
    # Final summary
    print_success "Packages created successfully!"
    echo ""
    echo -e "${GREEN}📦 Created Packages:${NC}"
    echo "  Universal DMG: $PACKAGES_DIR/$PROJECT_NAME-Universal-v$VERSION.dmg"
    echo "  Silicon DMG:   $PACKAGES_DIR/$PROJECT_NAME-Silicon-v$VERSION.dmg"
    echo "  Universal ZIP: $PACKAGES_DIR/$PROJECT_NAME-Universal-v$VERSION.zip"
    echo "  Silicon ZIP:   $PACKAGES_DIR/$PROJECT_NAME-Silicon-v$VERSION.zip"
    echo "  Release Notes: $PACKAGES_DIR/RELEASE_NOTES_v$VERSION.md"
    echo "  Checksums:     $PACKAGES_DIR/CHECKSUMS_v$VERSION.txt"
    echo ""
    echo -e "${BLUE}📋 Package Contents:${NC}"
    echo "  • DMG files: App + Release Notes (no ZIP files)"
    echo "  • ZIP files: App + Release Notes"
    echo "  • All packages include checksums for verification"
    echo ""
    print_success "Distribution packages ready! 🎉"
}

# Function to diagnose version issues
diagnose_version() {
    print_status "Diagnosing version information..."
    echo ""
    
    # Check Info.plist
    local info_plist_path="LearnMorseCode/Info.plist"
    if [[ -f "$info_plist_path" ]]; then
        local plist_version=$(plutil -extract CFBundleShortVersionString raw "$info_plist_path" 2>/dev/null || echo "unknown")
        local plist_build=$(plutil -extract CFBundleVersion raw "$info_plist_path" 2>/dev/null || echo "unknown")
        echo -e "${BLUE}📄 Info.plist:${NC} $plist_version (Build $plist_build)"
    else
        echo -e "${RED}❌ Info.plist not found${NC}"
    fi
    
    # Check built app
    local built_app_path="/Users/vivek/Library/Developer/Xcode/DerivedData/LearnMorseCode-gidpnppgzrnbkeavhfhqcwhxietw/Build/Products/Debug/$PROJECT_NAME.app"
    if [[ -d "$built_app_path" ]]; then
        local built_version=$(plutil -extract CFBundleShortVersionString raw "$built_app_path/Contents/Info.plist" 2>/dev/null || echo "unknown")
        local built_build=$(plutil -extract CFBundleVersion raw "$built_app_path/Contents/Info.plist" 2>/dev/null || echo "unknown")
        echo -e "${BLUE}📱 Built App:${NC} $built_version (Build $built_build)"
    else
        echo -e "${YELLOW}⚠️  No built app found${NC}"
    fi
    
    # Check running processes
    local running_processes=$(pgrep -f "LearnMorseCode" | wc -l)
    if [[ $running_processes -gt 0 ]]; then
        echo -e "${BLUE}🔄 Running Processes:${NC} $running_processes instance(s)"
        pgrep -f "LearnMorseCode" | while read pid; do
            echo "  PID: $pid"
        done
    else
        echo -e "${GREEN}✅ No running instances${NC}"
    fi
    
    echo ""
}

# Function to clean build artifacts
clean_builds() {
    print_status "Cleaning build artifacts..."
    
    # Clean Xcode build artifacts
    xcodebuild clean -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME_NAME"
    
    # Clean derived data
    rm -rf ~/Library/Developer/Xcode/DerivedData/LearnMorseCode-*
    
    # Clean package directories
    rm -rf Packages/
    rm -rf Distribution/
    rm -rf Build/
    
    print_success "Build artifacts cleaned!"
}

# Function to parse command line arguments
parse_arguments() {
    COMMAND="debug"  # Default command
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            debug|release|run|test|packages|clean|diagnose|help|--help|-h)
                COMMAND="$1"
                shift
                ;;
            --version)
                if [[ -n "$2" && "$2" != --* ]]; then
                    VERSION="$2"
                    shift 2
                else
                    print_error "Error: --version requires a version number (e.g., 10.2025)"
                    exit 1
                fi
                ;;
            --build)
                if [[ -n "$2" && "$2" != --* ]]; then
                    BUILD_NUMBER="$2"
                    shift 2
                else
                    print_error "Error: --build requires a build number (e.g., 04.8)"
                    exit 1
                fi
                ;;
            --auto-version)
                AUTO_VERSION=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main script logic
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Handle version logic
    if [[ "$AUTO_VERSION" == true ]]; then
        print_status "Auto-generating version numbers..."
        local auto_version_info=$(generate_auto_version)
        VERSION=$(echo "$auto_version_info" | cut -d'|' -f1)
        BUILD_NUMBER=$(echo "$auto_version_info" | cut -d'|' -f2)
        print_status "Auto-generated version: $VERSION (Build $BUILD_NUMBER)"
    elif [[ "$COMMAND" == "packages" || "$COMMAND" == "test" ]]; then
        # For packages and test, always use current Info.plist values (tested version)
        print_status "$COMMAND command: using current tested version from Info.plist..."
        local current_version_info=$(read_current_version)
        VERSION=$(echo "$current_version_info" | cut -d'|' -f1)
        BUILD_NUMBER=$(echo "$current_version_info" | cut -d'|' -f2)
        print_status "Using current tested version: $VERSION (Build $BUILD_NUMBER)"
    elif [[ "$VERSION" == "$DEFAULT_VERSION" && "$BUILD_NUMBER" == "$DEFAULT_BUILD_NUMBER" ]]; then
        # For other commands, auto-increment build number for current day
        print_status "No version specified, auto-incrementing build number for current day..."
        local auto_version_info=$(generate_auto_version)
        VERSION=$(echo "$auto_version_info" | cut -d'|' -f1)
        BUILD_NUMBER=$(echo "$auto_version_info" | cut -d'|' -f2)
        print_status "Auto-incremented version: $VERSION (Build $BUILD_NUMBER)"
    fi
    
    # Update Info.plist with version numbers
    update_info_plist "$VERSION" "$BUILD_NUMBER"
    
    # Check prerequisites
    check_prerequisites
    
    # Show current version info
    print_status "Using version: $VERSION (Build $BUILD_NUMBER)"
    
    case $COMMAND in
        debug)
            build_debug
            ;;
        release)
            build_release
            ;;
        run)
            build_and_run
            ;;
        test)
            run_tests
            ;;
        packages)
            build_packages
            ;;
        clean)
            clean_builds
            ;;
        diagnose)
            diagnose_version
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
