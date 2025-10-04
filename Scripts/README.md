# Scripts Directory

This directory contains build, test, and utility scripts for the LearnMorseCode project.

## Build Scripts

### `build_and_run.sh`
**Purpose**: Quick debug build and run the app
**Usage**: `./Scripts/build_and_run.sh`
**Description**: 
- Builds the project in Debug configuration
- Runs the app immediately after successful build
- Uses derived data for faster subsequent builds
- Includes proper code signing settings

### `build_and_run_release.sh`
**Purpose**: Release build and run the app
**Usage**: `./Scripts/build_and_run_release.sh`
**Description**:
- Builds the project in Release configuration
- Optimized for performance and smaller binary size
- Runs the app after successful build
- Includes proper code signing settings

### `build_and_debug.sh`
**Purpose**: Debug build with verbose output
**Usage**: `./Scripts/build_and_debug.sh`
**Description**:
- Builds the project in Debug configuration
- Provides detailed build output for troubleshooting
- Useful for debugging build issues
- Includes proper code signing settings

## Test Scripts

### `run_tests_with_coverage.sh`
**Purpose**: Run tests and generate coverage report
**Usage**: `./Scripts/run_tests_with_coverage.sh`
**Description**:
- Runs all unit tests in the LearnMorseKit package
- Generates code coverage reports
- Outputs results to `CoverageReport/` directory
- Useful for ensuring test coverage

## Utility Scripts

### `grant_permissions_manual.sh`
**Purpose**: Help with microphone and speech recognition permission setup
**Usage**: `./Scripts/grant_permissions_manual.sh`
**Description**:
- Opens System Settings to the Microphone privacy section
- Provides step-by-step guidance for granting permissions
- Safe alternative to manual permission setup
- Does not modify system files or databases

## Prerequisites

All scripts require:
- macOS development environment
- Xcode command line tools
- Swift Package Manager
- Proper code signing setup (see [Code Signing Guide](../Docs/setup_xcode_signing.md))

## Troubleshooting

If scripts fail:
1. Ensure you have proper code signing set up in Xcode
2. Check that all dependencies are installed
3. Verify the project builds successfully in Xcode first
4. For permission issues, see the [troubleshooting section](../README.md#troubleshooting) in the main README

## Security Note

- All scripts are designed to be safe and non-destructive
- No scripts modify system files or databases
- The `grant_permissions_manual.sh` script only opens System Settings and provides guidance
- Always review script contents before running if you have security concerns
