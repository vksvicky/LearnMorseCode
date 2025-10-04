#!/bin/bash

# Learn Morse Code - Build and Run Script
# This script builds and runs the Learn Morse Code macOS app

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="LearnMorseCode"
SCHEME_NAME="LearnMorseCode"
BUNDLE_ID="club.cycleruncode.LearnMorseCode"
BUILD_DIR="build"
DERIVED_DATA_DIR="DerivedData"

echo -e "${BLUE}🚀 Learn Morse Code - Build and Run Script${NC}"
echo "================================================"

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

# Check if we're in the right directory
if [ ! -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
    print_error "Xcode project not found. Please run this script from the project root directory."
    exit 1
fi

# Clean previous builds
print_status "Cleaning previous builds..."
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
if [ -d "$DERIVED_DATA_DIR" ]; then
    rm -rf "$DERIVED_DATA_DIR"
fi

# Clean Xcode build folder
print_status "Cleaning Xcode build folder..."
xcodebuild clean \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration Debug \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGN_STYLE=Automatic \
    INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
    INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning." \
    -quiet

print_success "Clean completed"

# Build the project
print_status "Building ${PROJECT_NAME}..."
xcodebuild build \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration Debug \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    -destination "platform=macOS" \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGN_STYLE=Automatic \
    INFOPLIST_KEY_NSSpeechRecognitionUsageDescription="This app uses speech recognition to convert your voice to text, which is then translated to Morse code for learning purposes." \
    INFOPLIST_KEY_NSMicrophoneUsageDescription="This app uses the microphone to record your voice for speech recognition and Morse code learning." \
    -quiet

if [ $? -eq 0 ]; then
    print_success "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi

# Find the built app
APP_PATH=$(find "$DERIVED_DATA_DIR" -name "*.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    print_error "Could not find built app"
    exit 1
fi

print_success "Found app at: $APP_PATH"

# Check if app is already running and kill it
print_status "Checking for running instances..."
if pgrep -f "$BUNDLE_ID" > /dev/null; then
    print_warning "App is already running. Terminating existing instance..."
    pkill -f "$BUNDLE_ID"
    sleep 2
fi

# Run the app
print_status "Launching ${PROJECT_NAME}..."
open "$APP_PATH"

if [ $? -eq 0 ]; then
    print_success "App launched successfully!"
    echo -e "${GREEN}🎉 Learn Morse Code is now running!${NC}"
else
    print_error "Failed to launch app"
    exit 1
fi

# Optional: Show app info
echo ""
echo "App Information:"
echo "  Name: $PROJECT_NAME"
echo "  Bundle ID: $BUNDLE_ID"
echo "  Path: $APP_PATH"
echo ""
echo "To stop the app, use: pkill -f '$BUNDLE_ID'"
echo "To rebuild, run this script again"
