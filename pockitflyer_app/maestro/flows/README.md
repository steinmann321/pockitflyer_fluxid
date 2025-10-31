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
