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
