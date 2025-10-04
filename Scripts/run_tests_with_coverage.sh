#!/bin/bash

# Learn Morse Code - Test Runner with Coverage Report
# This script runs all tests and generates a comprehensive coverage report

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
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

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================================${NC}"
}

# Function to check if we're in the right directory
check_directory() {
    if [ ! -f "LearnMorseCode.xcodeproj/project.pbxproj" ]; then
        print_error "Please run this script from the LearnMorseCode project root directory"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --spm-only     Run only Swift Package Manager tests"
    echo "  -x, --xcode-only   Run only Xcode tests"
    echo "  -a, --all          Run all tests (default)"
    echo "  -c, --coverage     Generate coverage report only"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                 # Run all tests with coverage"
    echo "  $0 -s              # Run only SPM tests"
    echo "  $0 -x              # Run only Xcode tests"
    echo "  $0 -c              # Generate coverage report only"
}

# Default values
RUN_SPM=true
RUN_XCODE=true
GENERATE_COVERAGE=true
COVERAGE_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--spm-only)
            RUN_SPM=true
            RUN_XCODE=false
            shift
            ;;
        -x|--xcode-only)
            RUN_SPM=false
            RUN_XCODE=true
            shift
            ;;
        -a|--all)
            RUN_SPM=true
            RUN_XCODE=true
            shift
            ;;
        -c|--coverage)
            COVERAGE_ONLY=true
            RUN_SPM=false
            RUN_XCODE=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if we're in the right directory
check_directory

# Create coverage report directory
COVERAGE_DIR="CoverageReport"
mkdir -p "$COVERAGE_DIR"

print_header "Learn Morse Code - Test Runner with Coverage"

# Function to run Swift Package Manager tests
run_spm_tests() {
    print_header "Running Swift Package Manager Tests"
    
    print_status "Running SPM tests with coverage..."
    
    # Ensure CoverageReport directory exists
    mkdir -p "$COVERAGE_DIR"
    
    # Store the absolute path to the coverage directory and project root
    ABSOLUTE_COVERAGE_DIR="$(pwd)/$COVERAGE_DIR"
    PROJECT_ROOT="$(pwd)"
    
    cd Modules/LearnMorseKit
    
    # Run tests with coverage
    swift test --enable-code-coverage 2>&1 | tee "$ABSOLUTE_COVERAGE_DIR/test_results_spm.txt"
    
    # Check if tests passed
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "SPM tests passed!"
    else
        print_error "SPM tests failed!"
        cd "$PROJECT_ROOT"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
    print_success "SPM tests completed successfully"
}

# Function to run Xcode tests
run_xcode_tests() {
    print_header "Running Xcode Tests"
    
    print_status "Running Xcode tests with coverage..."
    
    # Ensure we're in the project root directory
    cd "$(dirname "$0")"
    
    # Ensure CoverageReport directory exists
    mkdir -p "$COVERAGE_DIR"
    
    # Run Xcode tests with coverage
    xcodebuild test \
        -project LearnMorseCode.xcodeproj \
        -scheme LearnMorseCode \
        -destination 'platform=macOS' \
        -enableCodeCoverage YES \
        -derivedDataPath DerivedData \
        2>&1 | tee "$COVERAGE_DIR/test_results_xcode.txt"
    
    # Check if tests passed
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Xcode tests passed!"
    else
        print_error "Xcode tests failed!"
        return 1
    fi
    
    print_success "Xcode tests completed successfully"
}

# Function to generate coverage report
generate_coverage_report() {
    print_header "Generating Coverage Report"
    
    # Ensure we're in the project root directory
    cd "$(dirname "$0")"
    
    # Check if we have coverage data
    if [ ! -d "DerivedData" ]; then
        print_warning "No coverage data found. Run tests first."
        return 1
    fi
    
    print_status "Extracting coverage data..."
    
    # Find the coverage data file
    COVERAGE_FILE=$(find DerivedData -name "*.profdata" | head -1)
    
    if [ -z "$COVERAGE_FILE" ]; then
        print_error "No coverage data file found!"
        return 1
    fi
    
    print_status "Coverage data found: $COVERAGE_FILE"
    
    # Find the actual binary with coverage data
    # For SwiftUI apps, coverage data is typically in the test bundle
    BINARY_PATH=""
    
    # First, try the test bundle (most likely to have coverage data)
    TEST_BUNDLE=$(find DerivedData -name "LearnMorseCodeTests.xctest" -type d | head -1)
    if [ -n "$TEST_BUNDLE" ] && [ -d "$TEST_BUNDLE" ]; then
        TEST_BINARY="$TEST_BUNDLE/Contents/MacOS/LearnMorseCodeTests"
        if [ -f "$TEST_BINARY" ]; then
            # Test if this binary has coverage data
            if xcrun llvm-cov report -instr-profile "$COVERAGE_FILE" "$TEST_BINARY" >/dev/null 2>&1; then
                BINARY_PATH="$TEST_BINARY"
                print_status "Using test bundle for coverage: $BINARY_PATH"
            fi
        fi
    fi
    
    # If test bundle doesn't work, try the main app binary
    if [ -z "$BINARY_PATH" ]; then
        if [ -f "DerivedData/Build/Products/Debug/LearnMorseCode.app/Contents/MacOS/LearnMorseCode" ]; then
            BINARY_PATH="DerivedData/Build/Products/Debug/LearnMorseCode.app/Contents/MacOS/LearnMorseCode"
        elif [ -f "DerivedData/Build/Products/Debug/LearnMorseCode.app/Contents/MacOS/LearnMorseCode.debug.dylib" ]; then
            BINARY_PATH="DerivedData/Build/Products/Debug/LearnMorseCode.app/Contents/MacOS/LearnMorseCode.debug.dylib"
        fi
        
        if [ -n "$BINARY_PATH" ]; then
            # Test if this binary has coverage data
            if xcrun llvm-cov report -instr-profile "$COVERAGE_FILE" "$BINARY_PATH" >/dev/null 2>&1; then
                print_status "Using main app binary for coverage: $BINARY_PATH"
            else
                BINARY_PATH=""
            fi
        fi
    fi
    
    if [ -z "$BINARY_PATH" ]; then
        print_error "No suitable binary found with coverage data"
        return 1
    fi
    
    # Generate coverage report
    print_status "Generating HTML coverage report..."
    if xcrun llvm-cov show \
        -instr-profile "$COVERAGE_FILE" \
        -format html \
        -output-dir "$COVERAGE_DIR/html" \
        "$BINARY_PATH" 2>/dev/null; then
        print_success "HTML coverage report generated successfully"
    else
        print_warning "Failed to generate HTML coverage report. Trying text-only report..."
    fi
    
    # Generate text coverage report
    print_status "Generating text coverage report..."
    if xcrun llvm-cov report \
        -instr-profile "$COVERAGE_FILE" \
        "$BINARY_PATH" > "$COVERAGE_DIR/coverage_report.txt" 2>/dev/null; then
        print_success "Text coverage report generated successfully"
    else
        print_warning "Failed to generate text coverage report"
        echo "Coverage data found but could not generate report for binary: $BINARY_PATH" > "$COVERAGE_DIR/coverage_report.txt"
    fi
    
    # Generate JSON coverage data
    print_status "Generating JSON coverage data..."
    if xcrun llvm-cov export \
        -instr-profile "$COVERAGE_FILE" \
        -format json \
        "$BINARY_PATH" > "$COVERAGE_DIR/coverage_data.json" 2>/dev/null; then
        print_success "JSON coverage data generated successfully"
    else
        print_warning "Failed to generate JSON coverage data"
        echo '{"error": "Could not generate coverage data"}' > "$COVERAGE_DIR/coverage_data.json"
    fi
    
    # Generate summary
    print_status "Generating coverage summary..."
    cat > "$COVERAGE_DIR/coverage_summary.md" << EOF
# Learn Morse Code - Test Coverage Report

Generated on: $(date)

## Coverage Summary

### Swift Package Manager Tests
- **MorseCore Tests**: MorseCodeModel, MorseDecoder, MorseEncoder
- **Location**: \`Modules/LearnMorseKit/Tests/MorseCoreTests/\`

### Xcode Tests
- **Unit Tests**: LearnMorseCodeTests
- **UI Tests**: LearnMorseCodeUITests, LearnMorseCodeUITestsLaunchTests
- **Location**: \`LearnMorseCodeTests/\`, \`LearnMorseCodeUITests/\`

## Files Generated
- \`coverage_report.txt\` - Text coverage report
- \`coverage_data.json\` - JSON coverage data
- \`html/\` - HTML coverage report (open index.html in browser)

## Test Results
- \`test_results_spm.txt\` - Swift Package Manager test results
- \`test_results_xcode.txt\` - Xcode test results

## Coverage Files
- \`$COVERAGE_FILE\` - Raw coverage data
EOF
    
    print_success "Coverage report generated successfully!"
    print_status "HTML report: $COVERAGE_DIR/html/index.html"
    print_status "Text report: $COVERAGE_DIR/coverage_report.txt"
    print_status "JSON data: $COVERAGE_DIR/coverage_data.json"
}

# Function to show test summary
show_test_summary() {
    print_header "Test Summary"
    
    if [ "$RUN_SPM" = true ]; then
        if [ -f "$COVERAGE_DIR/test_results_spm.txt" ]; then
            print_status "SPM Test Results:"
            grep -E "(Test Suite|Test Case|PASS|FAIL)" "$COVERAGE_DIR/test_results_spm.txt" | tail -10
        fi
    fi
    
    if [ "$RUN_XCODE" = true ]; then
        if [ -f "$COVERAGE_DIR/test_results_xcode.txt" ]; then
            print_status "Xcode Test Results:"
            grep -E "(Test Suite|Test Case|PASS|FAIL)" "$COVERAGE_DIR/test_results_xcode.txt" | tail -10
        fi
    fi
    
    if [ "$GENERATE_COVERAGE" = true ]; then
        if [ -f "$COVERAGE_DIR/coverage_report.txt" ]; then
            print_status "Coverage Summary:"
            head -20 "$COVERAGE_DIR/coverage_report.txt"
        fi
    fi
}

# Main execution
main() {
    # Run tests if not coverage-only mode
    if [ "$COVERAGE_ONLY" = false ]; then
        if [ "$RUN_SPM" = true ]; then
            run_spm_tests
        fi
        
        if [ "$RUN_XCODE" = true ]; then
            run_xcode_tests
        fi
    fi
    
    # Generate coverage report if requested
    if [ "$GENERATE_COVERAGE" = true ]; then
        generate_coverage_report
    fi
    
    # Show summary
    show_test_summary
    
    print_header "Test Run Complete"
    print_success "All requested operations completed successfully!"
    
    if [ "$GENERATE_COVERAGE" = true ]; then
        print_status "Coverage report available in: $COVERAGE_DIR/"
        print_status "Open $COVERAGE_DIR/html/index.html in your browser to view detailed coverage"
    fi
}

# Run main function
main "$@"
