---
id: m04-e03-t09
title: E2E Expiration Workflow
epic: m04-e03
status: pending
---

# Task: E2E Expiration Workflow

## Description
E2E test validating complete expiration workflow: flyer expires, disappears from feed, appears as expired on profile, can be extended and reactivated.

## Scope
- Create test flyer with expiration date
- Wait for expiration (or mock time)
- Verify flyer removed from public feed
- Verify flyer still visible on profile with expired status
- Extend expiration date without reactivation
- Verify flyer still inactive
- Reactivate flyer with new expiration
- Verify flyer appears in public feed again
- Run on iOS simulator
- Use Maestro E2E framework

## Success Criteria
- [ ] Test creates flyer with near-future expiration
- [ ] Test waits for expiration (or mocks time)
- [ ] Verifies flyer removed from public feed
- [ ] Verifies flyer on profile with "expired" indicator
- [ ] Extends expiration without reactivation
- [ ] Verifies flyer still marked expired
- [ ] Reactivates flyer with new expiration
- [ ] Verifies flyer appears in feed again
- [ ] Test passes consistently
- [ ] Test runs in CI/CD pipeline
- [ ] All test code marked with `tdd_green` tag

## Test Flow
```yaml
# maestro test flow
appId: com.pockitflyer.app
---
# Setup: Create flyer expiring in 1 minute
- tapOn: "Create Flyer"
- inputText: "Test Expiring Flyer"
- tapOn: "Expiration Date"
# Set expiration to 1 minute from now
- tapOn: "Publish"

# Wait for expiration
- waitForAnimationToEnd:
    timeout: 65000  # Wait 65 seconds

# Verify removed from feed
- tapOn: "Feed"
- assertNotVisible: "Test Expiring Flyer"

# Verify visible on profile as expired
- tapOn: "Profile"
- assertVisible: "Test Expiring Flyer"
- assertVisible: "Expired"

# Extend expiration without reactivation
- tapOn: "Test Expiring Flyer"
- tapOn: "Edit"
- tapOn: "Expiration Date"
# Set new future date
- tapOn: "Save"

# Verify still expired
- back
- assertVisible: "Expired"

# Reactivate flyer
- tapOn: "Test Expiring Flyer"
- tapOn: "Edit"
- tapOn: "Reactivate"
- tapOn: "Save"

# Verify appears in feed
- tapOn: "Feed"
- assertVisible: "Test Expiring Flyer"
- assertNotVisible: "Expired"
```

## Dependencies
- M04-E03-T01 through T08 (all implementation tasks)

## Acceptance
- E2E test passes
- Workflow validated end-to-end
- Test documented and maintainable
