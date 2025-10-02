#!/bin/bash

# Learn Morse Code - Build and Debug Script
# This script builds the app and keeps the terminal open to show debug logs

echo "🚀 Learn Morse Code - Build and Debug Script"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
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

# Clean previous builds
print_info "Cleaning previous builds..."
print_info "Cleaning Xcode build folder..."

if xcodebuild clean -project LearnMorseCode.xcodeproj -scheme LearnMorseCode -destination "platform=macOS" > /dev/null 2>&1; then
    print_success "Clean completed"
else
    print_warning "Clean failed or no previous build found"
fi

# Build the project
print_info "Building LearnMorseCode..."

if xcodebuild build -project LearnMorseCode.xcodeproj -scheme LearnMorseCode -destination "platform=macOS" -derivedDataPath DerivedData; then
    print_success "Build completed successfully"
    
    # Find the app
    APP_PATH="DerivedData/Build/Products/Debug/LearnMorseCode.app"
    if [ -d "$APP_PATH" ]; then
        print_success "Found app at: $APP_PATH"
        
        # Check and handle existing instances
        print_info "Checking for running instances..."
        if pgrep -f "LearnMorseCode" > /dev/null; then
            print_warning "Found existing instance of LearnMorseCode running"
            print_info "Killing existing instance..."
            pkill -f "LearnMorseCode"
            sleep 2
            # Also try killing by bundle ID
            pkill -f "club.cycleruncode.LearnMorseCode"
            sleep 2
            # Verify it was killed
            if pgrep -f "LearnMorseCode" > /dev/null; then
                print_warning "Force killing remaining processes..."
                pkill -9 -f "LearnMorseCode"
                pkill -9 -f "club.cycleruncode.LearnMorseCode"
                sleep 2
            fi
            print_success "Existing instance terminated"
        else
            print_info "No existing instances found"
        fi
        
        # Launch the app and capture its output
        print_info "Launching LearnMorseCode with debug output..."
        
        # Actually launch the app
        open "$APP_PATH"
        
        # Wait for the app to start
        sleep 3
        
        print_success "App launched successfully!"
        echo ""
        echo "🎉 Learn Morse Code is now running with debug output!"
        echo "App Information:"
        echo "  Name: LearnMorseCode"
        echo "  Bundle ID: club.cycleruncode.LearnMorseCode"
        echo "  Path: $APP_PATH"
        echo ""
        echo "📱 Debug logs will appear below. Try using the app to see audio debug output:"
        echo "   - Go to Text↔Morse tab"
        echo "   - Enter some text (e.g., 'HELLO')"
        echo "   - Click 'Convert to Morse'"
        echo "   - Click 'Play' button"
        echo ""
        echo "Press Ctrl+C to stop the app and exit this script"
        echo "================================================"
        echo ""
        
        # Try to get logs from the app
        print_info "Following app logs (if available)..."
        echo ""
        
        # Use log stream to follow app logs with more comprehensive filtering
        log stream --predicate 'process == "LearnMorseCode" OR processImagePath CONTAINS "LearnMorseCode"' --style compact --color always
        
    else
        print_error "App not found at expected location: $APP_PATH"
        exit 1
    fi
else
    print_error "Build failed"
    exit 1
fi
