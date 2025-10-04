#!/bin/bash

# Learn Morse Code - Manual Permission Grant Script
# This script helps you grant permissions manually through System Settings

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BUNDLE_ID="club.cycleruncode.LearnMorseCode"

echo -e "${BLUE}🔐 Learn Morse Code - Manual Permission Grant${NC}"
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

print_status "Since the app is not properly signed, it won't appear in System Settings."
print_status "However, we can try to grant permissions manually."
echo ""

# Check if the app is running
if ! pgrep -f "$BUNDLE_ID" > /dev/null; then
    print_warning "Learn Morse Code is not running. Please start the app first."
    echo "Run the app from Xcode (Cmd+R)"
    exit 1
fi

print_success "Learn Morse Code is running."

# Try to open System Settings to the microphone section
print_status "Opening System Settings to Microphone permissions..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"

echo ""
print_status "Manual Steps:"
echo "1. In System Settings, look for 'LearnMorseCode' in the Microphone list"
echo "2. If you see it, toggle it ON"
echo "3. If you don't see it, the app needs to be properly signed"
echo ""
print_status "Alternative: Try the Voice to Morse feature in the app"
print_status "When prompted for permissions, click 'Allow'"
echo ""

# Wait a moment for System Settings to open
sleep 2

print_status "If the app doesn't appear in System Settings, you need to:"
echo "1. In Xcode, go to Signing & Capabilities"
echo "2. Select your Apple ID in the Team dropdown"
echo "3. Clean and rebuild the project (Cmd+Shift+K, then Cmd+R)"
echo ""
print_status "This will properly sign the app and make it appear in System Settings."
