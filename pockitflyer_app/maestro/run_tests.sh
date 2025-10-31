#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
FLOW=""
DEVICE=""
PLATFORM=""
BUILD=false
CONTINUOUS=false
VERBOSE=false
CLEAN=false
REPORT_DIR="maestro-reports"

# Helper functions
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

show_help() {
    cat << HELP
Maestro Test Runner

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help
    -f, --flow FLOW         Run specific flow (file name without .yaml)
    -d, --device DEVICE     Target device (iOS Simulator name or Android emulator ID)
    -p, --platform ios|android  Build for specific platform
    -b, --build             Build app before running tests
    -c, --continuous        Run in continuous mode (watch for changes)
    -v, --verbose           Verbose output
    --clean                 Clean old reports before running
    --list-devices          List available devices
    --list-flows            List available test flows

EXAMPLES:
    $0                                  # Run all flows
    $0 -f app_launch                    # Run specific flow
    $0 -b -p ios                        # Build iOS and run all flows
    $0 -d "iPhone 15 Pro"               # Run on specific device
    $0 -c                               # Continuous mode
HELP
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -f|--flow) FLOW="$2"; shift 2 ;;
        -d|--device) DEVICE="$2"; shift 2 ;;
        -p|--platform) PLATFORM="$2"; shift 2 ;;
        -b|--build) BUILD=true; shift ;;
        -c|--continuous) CONTINUOUS=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        --clean) CLEAN=true; shift ;;
        --list-devices) maestro test --list-devices; exit 0 ;;
        --list-flows) ls -1 maestro/flows/*.yaml 2>/dev/null | xargs -n 1 basename; exit 0 ;;
        *) print_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# Validate Maestro installation
if ! command -v maestro &> /dev/null; then
    print_error "Maestro CLI not found. Install it from https://maestro.mobile.dev"
    exit 1
fi

# Clean reports
if [ "$CLEAN" = true ]; then
    print_info "Cleaning old reports..."
    rm -rf "$REPORT_DIR"
fi

# Create report directory
mkdir -p "$REPORT_DIR"

# Build app if requested
if [ "$BUILD" = true ]; then
    print_info "Building app for $PLATFORM..."
    if [ "$PLATFORM" = "ios" ]; then
        flutter build ios --simulator --debug
    elif [ "$PLATFORM" = "android" ]; then
        flutter build apk --debug
    else
        print_error "Platform must be 'ios' or 'android'"
        exit 1
    fi
    print_success "Build complete"
fi

# Prepare maestro command
MAESTRO_CMD="maestro test"

if [ -n "$DEVICE" ]; then
    MAESTRO_CMD="$MAESTRO_CMD --device \"$DEVICE\""
fi

if [ "$CONTINUOUS" = true ]; then
    MAESTRO_CMD="$MAESTRO_CMD --continuous"
fi

# Add report output
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAESTRO_CMD="$MAESTRO_CMD --format junit --output $REPORT_DIR/results_$TIMESTAMP.xml"

# Select flows
if [ -n "$FLOW" ]; then
    FLOWS="maestro/flows/${FLOW}.yaml"
else
    FLOWS="maestro/flows"
fi

# Run tests
print_info "Running Maestro tests..."
eval "$MAESTRO_CMD $FLOWS"

print_success "Tests complete! Reports saved to: $REPORT_DIR/"
