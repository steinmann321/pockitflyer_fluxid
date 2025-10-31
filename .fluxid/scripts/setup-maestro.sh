#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default values
FLUTTER_APP_DIR=""
MAESTRO_VERSION="1.38.0"
SKIP_HOOKS=false
SKIP_INSTALL=false
VERBOSE=false

# Helper functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

show_usage() {
    cat << EOF
Maestro E2E Test Setup Script v${SCRIPT_VERSION}

USAGE:
    $0 [OPTIONS] [FLUTTER_APP_DIR]

DESCRIPTION:
    Sets up Maestro E2E testing infrastructure for a Flutter application.
    Creates directory structure, installs Maestro CLI, configures pre-commit hooks,
    and generates starter test flows.

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    --skip-hooks            Skip pre-commit hooks installation
    --skip-install          Skip Maestro CLI installation (assumes already installed)
    --version VERSION       Specify Maestro version to install (default: ${MAESTRO_VERSION})

ARGUMENTS:
    FLUTTER_APP_DIR         Path to Flutter app directory (default: auto-detect)
                           Can be absolute or relative to project root

EXAMPLES:
    # Auto-detect Flutter app directory
    $0

    # Specify Flutter app directory
    $0 pockitflyer_app

    # Skip hooks installation
    $0 --skip-hooks pockitflyer_app

    # Custom Maestro version
    $0 --version 1.39.0 pockitflyer_app

    # Skip CLI installation (already installed)
    $0 --skip-install pockitflyer_app

DIRECTORY STRUCTURE CREATED:
    {FLUTTER_APP_DIR}/
    ├── maestro/
    │   ├── config/
    │   │   └── maestro.yaml           # Global configuration
    │   ├── flows/                      # Test flows (YAML)
    │   │   ├── app_launch.yaml        # Starter smoke test
    │   │   └── README.md
    │   ├── utils/                      # Reusable components
    │   ├── .maestro-version            # CLI version pin
    │   ├── run_tests.sh                # Test runner script
    │   └── README.md                   # Documentation
    └── Makefile                        # Make commands (if not exists)

PRE-COMMIT HOOKS:
    .git/hooks/pre-commit
    .fluxid/hooks/flutter/
    ├── 01_enforce_test_identifiers.sh
    ├── 02_enforce_input_validation.sh
    ├── 03_enforce_loading_states.sh
    ├── 04_enforce_error_handling.sh
    ├── 05_no_hardcoded_text.sh
    ├── 06_enforce_semantics.sh
    ├── 07_no_direct_api_calls.sh
    └── 08_no_setstate_in_build.sh

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --skip-hooks)
                SKIP_HOOKS=true
                shift
                ;;
            --skip-install)
                SKIP_INSTALL=true
                shift
                ;;
            --version)
                MAESTRO_VERSION="$2"
                shift 2
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                FLUTTER_APP_DIR="$1"
                shift
                ;;
        esac
    done
}

# Auto-detect Flutter app directory
auto_detect_flutter_app() {
    log_verbose "Auto-detecting Flutter app directory..."

    # Search for pubspec.yaml in common locations
    local candidates=(
        "pockitflyer_app"
        "app"
        "flutter_app"
        "."
    )

    for candidate in "${candidates[@]}"; do
        local path="$PROJECT_ROOT/$candidate"
        if [ -f "$path/pubspec.yaml" ]; then
            log_verbose "Found pubspec.yaml at: $path/pubspec.yaml"

            # Check if it's a Flutter app (contains flutter dependency)
            if grep -q "^  flutter:" "$path/pubspec.yaml"; then
                FLUTTER_APP_DIR="$candidate"
                print_success "Auto-detected Flutter app: $FLUTTER_APP_DIR"
                return 0
            fi
        fi
    done

    print_error "Could not auto-detect Flutter app directory"
    print_info "Please specify the Flutter app directory as an argument"
    exit 1
}

# Validate Flutter app directory
validate_flutter_app() {
    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"

    log_verbose "Validating Flutter app at: $app_path"

    if [ ! -d "$app_path" ]; then
        print_error "Flutter app directory does not exist: $app_path"
        exit 1
    fi

    if [ ! -f "$app_path/pubspec.yaml" ]; then
        print_error "No pubspec.yaml found in: $app_path"
        exit 1
    fi

    if ! grep -q "^  flutter:" "$app_path/pubspec.yaml"; then
        print_error "Not a Flutter app (no flutter dependency in pubspec.yaml)"
        exit 1
    fi

    print_success "Validated Flutter app directory: $FLUTTER_APP_DIR"
}

# Check if Maestro is installed
check_maestro_installed() {
    if command -v maestro &> /dev/null; then
        local current_version
        current_version=$(maestro --version 2>&1 | head -n 1 || echo "unknown")
        print_success "Maestro CLI is installed: $current_version"
        return 0
    else
        print_warning "Maestro CLI is not installed"
        return 1
    fi
}

# Install Maestro CLI
install_maestro() {
    if [ "$SKIP_INSTALL" = true ]; then
        print_info "Skipping Maestro CLI installation (--skip-install)"
        if ! check_maestro_installed; then
            print_error "Maestro CLI is not installed and --skip-install was specified"
            exit 1
        fi
        return 0
    fi

    print_header "Installing Maestro CLI"

    if check_maestro_installed; then
        print_info "Maestro CLI already installed"
        return 0
    fi

    print_info "Installing Maestro CLI v${MAESTRO_VERSION}..."

    # Install Maestro
    if curl -Ls "https://get.maestro.mobile.dev" | bash; then
        print_success "Maestro CLI installed successfully"
    else
        print_error "Failed to install Maestro CLI"
        exit 1
    fi

    # Add to PATH for current session
    export PATH="$PATH:$HOME/.maestro/bin"

    # Verify installation
    if check_maestro_installed; then
        print_success "Maestro CLI is ready to use"
        print_info "Add to your shell profile: export PATH=\"\$PATH:\$HOME/.maestro/bin\""
    else
        print_error "Maestro CLI installation verification failed"
        exit 1
    fi
}

# Create maestro directory structure
create_directory_structure() {
    print_header "Creating Maestro Directory Structure"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local maestro_dir="$app_path/maestro"

    log_verbose "Creating directories in: $maestro_dir"

    # Create main directories
    mkdir -p "$maestro_dir/config"
    mkdir -p "$maestro_dir/flows"
    mkdir -p "$maestro_dir/utils"

    print_success "Created directory structure at: $maestro_dir"
}

# Create maestro configuration file
create_maestro_config() {
    print_header "Creating Maestro Configuration"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local config_file="$app_path/maestro/config/maestro.yaml"

    # Extract app ID from pubspec.yaml (use package name as app ID)
    local app_id
    app_id=$(grep "^name:" "$app_path/pubspec.yaml" | awk '{print $2}' | tr -d '\r')

    # Default to com.example.appname if not found
    if [ -z "$app_id" ]; then
        app_id="com.example.pockitflyerApp"
    else
        app_id="com.example.${app_id}"
    fi

    log_verbose "Using app ID: $app_id"

    cat > "$config_file" << EOF
# Maestro Global Configuration
# This file contains global settings for all Maestro test flows

appId: ${app_id}

env:
  # Timeout for driver startup (milliseconds)
  MAESTRO_DRIVER_STARTUP_TIMEOUT: 120000  # 2 minutes

  # Default timeout for individual commands (milliseconds)
  MAESTRO_COMMAND_TIMEOUT: 15000          # 15 seconds

# Tags for organizing and filtering tests
tags:
  - e2e
  - mobile
EOF

    print_success "Created maestro config: maestro/config/maestro.yaml"
    print_info "App ID: $app_id"
}

# Create version pin file
create_version_file() {
    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local version_file="$app_path/maestro/.maestro-version"

    echo "$MAESTRO_VERSION" > "$version_file"

    print_success "Created version pin: maestro/.maestro-version ($MAESTRO_VERSION)"
}

# Create starter test flows
create_starter_flows() {
    print_header "Creating Starter Test Flows"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local flows_dir="$app_path/maestro/flows"

    # Extract app ID
    local app_id
    app_id=$(grep "^name:" "$app_path/pubspec.yaml" | awk '{print $2}' | tr -d '\r')
    if [ -z "$app_id" ]; then
        app_id="com.example.pockitflyerApp"
    else
        app_id="com.example.${app_id}"
    fi

    # Create app_launch.yaml
    cat > "$flows_dir/app_launch.yaml" << EOF
appId: ${app_id}
---
# Smoke Test: App Launch
# Verifies that the app launches successfully and the home page loads

- launchApp
- assertVisible: ".*"  # Assert any visible content (adjust based on your app)
EOF

    print_success "Created starter flow: maestro/flows/app_launch.yaml"

    # Create flows README
    cat > "$flows_dir/README.md" << 'EOF'
# Maestro Test Flows

This directory contains Maestro test flows written in YAML format.

## Running Tests

```bash
# Run all flows
maestro test maestro/flows

# Run specific flow
maestro test maestro/flows/app_launch.yaml

# Run with test runner script
./maestro/run_tests.sh
```

## Writing Test Flows

Each flow file should:
1. Start with `appId: your.app.id`
2. Use `---` separator
3. Define test steps using Maestro commands

### Example Flow

```yaml
appId: com.example.yourapp
---
# Test Description

- launchApp
- assertVisible: "Welcome"
- tapOn: "Get Started"
- assertVisible: "Home"
```

## Common Commands

- `launchApp` - Launch the application
- `assertVisible: "text"` - Assert text is visible
- `tapOn: "text"` - Tap on element with text
- `scroll` - Scroll down
- `swipe: {direction: LEFT}` - Swipe left/right/up/down
- `inputText: "text"` - Enter text
- `waitForAnimationToEnd: 1000` - Wait for animation (ms)

## Resources

- [Maestro Documentation](https://maestro.mobile.dev/)
- [Maestro Commands Reference](https://maestro.mobile.dev/reference/commands)
- [Maestro Best Practices](https://maestro.mobile.dev/best-practices/writing-flows)
EOF

    print_success "Created flows README: maestro/flows/README.md"
}

# Create test runner script
create_test_runner() {
    print_header "Creating Test Runner Script"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local runner_script="$app_path/maestro/run_tests.sh"

    cat > "$runner_script" << 'EOF'
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
EOF

    chmod +x "$runner_script"

    print_success "Created test runner: maestro/run_tests.sh"
}

# Create Makefile if it doesn't exist
create_makefile() {
    print_header "Creating Makefile"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local makefile="$app_path/Makefile"

    if [ -f "$makefile" ]; then
        print_info "Makefile already exists, skipping..."
        return 0
    fi

    cat > "$makefile" << 'EOF'
.PHONY: help maestro maestro-flow maestro-continuous maestro-ios maestro-android maestro-clean maestro-list e2e e2e-watch

help:
	@echo "Maestro E2E Test Commands:"
	@echo "  make maestro              - Run all Maestro tests"
	@echo "  make maestro-flow FLOW=<name> - Run specific flow"
	@echo "  make maestro-continuous   - Run in continuous mode"
	@echo "  make maestro-ios          - Build iOS and run tests"
	@echo "  make maestro-android      - Build Android and run tests"
	@echo "  make maestro-clean        - Clean test reports"
	@echo "  make maestro-list         - List available flows"
	@echo ""
	@echo "Aliases:"
	@echo "  make e2e                  - Alias for 'make maestro'"
	@echo "  make e2e-watch            - Alias for 'make maestro-continuous'"

maestro:
	./maestro/run_tests.sh

e2e: maestro

maestro-flow:
	@if [ -z "$(FLOW)" ]; then \
		echo "Error: FLOW variable is required. Usage: make maestro-flow FLOW=app_launch"; \
		exit 1; \
	fi
	./maestro/run_tests.sh -f $(FLOW)

maestro-continuous:
	./maestro/run_tests.sh -c

e2e-watch: maestro-continuous

maestro-ios:
	./maestro/run_tests.sh -b -p ios

maestro-android:
	./maestro/run_tests.sh -b -p android

maestro-clean:
	rm -rf maestro-reports/
	@echo "Cleaned maestro reports"

maestro-list:
	@ls -1 maestro/flows/*.yaml 2>/dev/null | xargs -n 1 basename || echo "No flows found"
EOF

    print_success "Created Makefile with Maestro commands"
}

# Create main README
create_main_readme() {
    print_header "Creating Documentation"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"
    local readme="$app_path/maestro/README.md"

    cat > "$readme" << 'EOF'
# Maestro E2E Tests

End-to-end testing setup using [Maestro](https://maestro.mobile.dev/) for Flutter application.

## Prerequisites

- Maestro CLI (installed automatically by setup script)
- iOS Simulator or Android Emulator
- Flutter SDK

## Installation

Maestro CLI is installed at: `~/.maestro/bin`

Add to your shell profile:
```bash
export PATH="$PATH:$HOME/.maestro/bin"
```

## Directory Structure

```
maestro/
├── config/
│   └── maestro.yaml           # Global configuration
├── flows/                      # Test flows (YAML files)
│   ├── app_launch.yaml        # Starter smoke test
│   └── README.md
├── utils/                      # Reusable test components
├── .maestro-version            # CLI version pin
├── run_tests.sh                # Test runner script
└── README.md                   # This file
```

## Running Tests

### Method 1: Shell Script (Recommended)

```bash
# Run all flows
./maestro/run_tests.sh

# Run specific flow
./maestro/run_tests.sh -f app_launch

# Continuous mode (watch for changes)
./maestro/run_tests.sh -c

# Build and test iOS
./maestro/run_tests.sh -b -p ios

# Run on specific device
./maestro/run_tests.sh -d "iPhone 15 Pro"

# Verbose output
./maestro/run_tests.sh -v

# Clean old reports
./maestro/run_tests.sh --clean

# Help
./maestro/run_tests.sh --help
```

### Method 2: Makefile

```bash
# Run all tests
make maestro

# Run specific flow
make maestro-flow FLOW=app_launch

# Continuous mode
make maestro-continuous

# Build and test
make maestro-ios
make maestro-android

# Clean reports
make maestro-clean

# List flows
make maestro-list
```

### Method 3: Direct Maestro Commands

```bash
# Run all flows
maestro test maestro/flows

# Run specific flow
maestro test maestro/flows/app_launch.yaml

# List available devices
maestro test --list-devices
```

## Writing Test Flows

Test flows are written in YAML format. See `flows/README.md` for detailed guide.

### Basic Example

```yaml
appId: com.example.yourapp
---
# Test: User Login Flow

- launchApp
- assertVisible: "Login"
- tapOn: "Email"
- inputText: "user@example.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Sign In"
- assertVisible: "Welcome"
```

## Test Reports

Reports are saved to `maestro-reports/` in JUnit XML format.

## Pre-commit Hooks

Pre-commit hooks enforce code quality and Maestro testability:

- Test identifiers (keys, Semantics)
- Input validation
- Loading states
- Error handling
- And more...

Run `.fluxid/scripts/maestro-hooks-setup.sh` to install hooks.

## Resources

- [Maestro Documentation](https://maestro.mobile.dev/)
- [Command Reference](https://maestro.mobile.dev/reference/commands)
- [Best Practices](https://maestro.mobile.dev/best-practices/writing-flows)
- [Maestro Cloud](https://cloud.mobile.dev/)

## Troubleshooting

### Maestro not found
```bash
export PATH="$PATH:$HOME/.maestro/bin"
maestro --version
```

### Tests failing
```bash
# Run with verbose output
./maestro/run_tests.sh -v

# Check device status
maestro test --list-devices

# Rebuild app
./maestro/run_tests.sh -b -p ios
```

### App ID mismatch
Check `maestro/config/maestro.yaml` and ensure `appId` matches your app's bundle identifier.
EOF

    print_success "Created main README: maestro/README.md"
}

# Install pre-commit hooks
install_hooks() {
    if [ "$SKIP_HOOKS" = true ]; then
        print_info "Skipping pre-commit hooks installation (--skip-hooks)"
        return 0
    fi

    print_header "Installing Pre-commit Hooks"

    local hooks_script="$SCRIPT_DIR/maestro-hooks-setup.sh"

    if [ ! -f "$hooks_script" ]; then
        print_warning "Hooks setup script not found: $hooks_script"
        print_info "Skipping hooks installation"
        return 0
    fi

    # Check if hooks script is executable
    if [ ! -x "$hooks_script" ]; then
        chmod +x "$hooks_script"
    fi

    # Run hooks setup script
    print_info "Running maestro-hooks-setup.sh..."
    if "$hooks_script" "$FLUTTER_APP_DIR"; then
        print_success "Pre-commit hooks installed successfully"
    else
        print_warning "Hooks installation completed with warnings"
    fi
}

# Print final summary
print_summary() {
    print_header "Setup Complete!"

    local app_path="$PROJECT_ROOT/$FLUTTER_APP_DIR"

    cat << EOF

${GREEN}Maestro E2E testing is ready to use!${NC}

${BLUE}Quick Start:${NC}

  1. Run starter test:
     ${YELLOW}cd $FLUTTER_APP_DIR && ./maestro/run_tests.sh${NC}

  2. Or use Make:
     ${YELLOW}cd $FLUTTER_APP_DIR && make maestro${NC}

  3. Watch mode (auto-run on changes):
     ${YELLOW}cd $FLUTTER_APP_DIR && make maestro-continuous${NC}

${BLUE}Files Created:${NC}

  📁 $FLUTTER_APP_DIR/maestro/
  ├── config/maestro.yaml       Global configuration
  ├── flows/app_launch.yaml     Starter smoke test
  ├── .maestro-version           CLI version pin ($MAESTRO_VERSION)
  ├── run_tests.sh               Test runner script
  └── README.md                  Documentation

${BLUE}Next Steps:${NC}

  1. Customize app ID in: maestro/config/maestro.yaml
  2. Update starter test in: maestro/flows/app_launch.yaml
  3. Write more test flows (see maestro/flows/README.md)
  4. Run tests: ./maestro/run_tests.sh --help

${BLUE}Documentation:${NC}

  📖 Maestro setup: $FLUTTER_APP_DIR/maestro/README.md
  📖 Writing flows: $FLUTTER_APP_DIR/maestro/flows/README.md
  📖 Maestro docs: https://maestro.mobile.dev

${GREEN}Happy Testing! 🚀${NC}

EOF
}

# Main execution
main() {
    print_header "Maestro E2E Test Setup v${SCRIPT_VERSION}"

    # Parse arguments
    parse_args "$@"

    # Auto-detect or validate Flutter app
    if [ -z "$FLUTTER_APP_DIR" ]; then
        auto_detect_flutter_app
    else
        validate_flutter_app
    fi

    # Install Maestro CLI
    install_maestro

    # Create directory structure
    create_directory_structure

    # Create configuration files
    create_maestro_config
    create_version_file

    # Create test flows
    create_starter_flows

    # Create scripts and documentation
    create_test_runner
    create_makefile
    create_main_readme

    # Install pre-commit hooks
    install_hooks

    # Print summary
    print_summary
}

# Run main function
main "$@"
