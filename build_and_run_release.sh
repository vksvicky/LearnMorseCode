#!/bin/bash

# LearnMorseCode - Build and Run Release Version
# This script builds the optimized Release version for faster launch times

set -e

echo "🚀 Building LearnMorseCode in Release mode..."

# Clean and build Release version
xcodebuild clean -project LearnMorseCode.xcodeproj -scheme LearnMorseCode
xcodebuild -project LearnMorseCode.xcodeproj -scheme LearnMorseCode -destination 'platform=macOS' -configuration Release build

echo "✅ Build completed successfully!"

# Launch the Release version
echo "🎯 Launching optimized app..."
open "/Users/vivek/Library/Developer/Xcode/DerivedData/LearnMorseCode-gidpnppgzrnbkeavhfhqcwhxietw/Build/Products/Release/LearnMorseCode.app"

echo "🎉 App launched! The Release version should start much faster than the Debug version."
