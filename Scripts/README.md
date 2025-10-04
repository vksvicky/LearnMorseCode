# Scripts Directory

This directory contains build, test, and utility scripts for the LearnMorseCode project.

## Universal Build Script

### `build.sh`
**Purpose**: Universal build script that handles all build scenarios
**Usage**: `./Scripts/build.sh [OPTION]`
**Description**: 
- Single script for all build operations
- Handles debug, release, test, and distribution builds
- Includes proper code signing and privacy descriptions
- Automatically installs dependencies when needed

**Options**:
- `debug` (default) - Build and run debug version (auto-increments build number)
- `release` - Build and run release version (auto-increments build number)
- `run` - Build and run app (auto-increments build number)
- `test` - Run tests with coverage
- `packages` - Build distribution packages (uses current tested version)
- `clean` - Clean build artifacts
- `help` - Show usage information

**Examples**:
```bash
./Scripts/build.sh                                          # Debug build and run (auto-increments build number)
./Scripts/build.sh debug                                    # Debug build and run (auto-increments build number)
./Scripts/build.sh release                                  # Release build and run (auto-increments build number)
./Scripts/build.sh run                                      # Build and run app (auto-increments build number)
./Scripts/build.sh test                                     # Run tests
./Scripts/build.sh packages                                 # Build Universal + Silicon packages (uses current tested version)
./Scripts/build.sh packages --version 10.2025               # Build packages (version parameters ignored - uses current tested version)
./Scripts/build.sh packages --version 10.2025 --build 04.8  # Build packages (version parameters ignored - uses current tested version)
./Scripts/build.sh clean                                    # Clean build artifacts
```

**Version Parameters**:
- `--version VERSION`: Set the version number (e.g., 10.2025)
- `--build BUILD_NUMBER`: Set the build number (e.g., 04.8)
- `--auto-version`: Auto-generate version (month.year) and build (day.build_number)

**Auto-Increment Behavior**:
- **Development builds** (debug/release/run): Auto-increments build number for current day
- **Same day**: Build number increments (e.g., 04.6 → 04.7 → 04.8)
- **New day**: Build number resets to day.1 (e.g., 04.8 → 05.1)
- **Packages and test commands**: Use current tested version (no auto-increment)
- **Version parameters ignored**: `--version`, `--build`, `--auto-version` are ignored for packages and test commands
- **Version format**: `month.year` (e.g., `10.2025` for October 2025)
- **Build format**: `day.build_number` (e.g., `04.6` for day 4, build 6)
- **No parameters needed**: Just run `./Scripts/build.sh` to auto-increment

## Utility Scripts

### `grant_permissions_manual.sh`
**Purpose**: Help with microphone and speech recognition permission setup
**Usage**: `./Scripts/grant_permissions_manual.sh`
**Description**:
- Opens System Settings to the Microphone privacy section
- Provides step-by-step guidance for granting permissions
- Safe alternative to manual permission setup
- Does not modify system files or databases

## Distribution Features

The `build.sh packages` command creates **both** Universal and Silicon packages:

### Package Types
- **Universal**: Runs on both Intel and Apple Silicon Macs
- **Silicon**: Optimized for Apple Silicon Macs only (smaller, faster)

### Package Formats
- **DMG Files**: Native macOS disk images for easy installation
- **ZIP Files**: Alternative installation method
- **Release Notes**: Comprehensive documentation with each package
- **Checksums**: For package verification and integrity

### Output Structure
```
Packages/
├── LearnMorseCode-Universal-v10.2025.dmg
├── LearnMorseCode-Universal-v10.2025.zip
├── LearnMorseCode-Silicon-v10.2025.dmg
├── LearnMorseCode-Silicon-v10.2025.zip
├── RELEASE_NOTES_v10.2025.md
└── CHECKSUMS_v10.2025.txt
```

**Note**: Both Universal and Silicon packages are always built together when using the `packages` command.

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
