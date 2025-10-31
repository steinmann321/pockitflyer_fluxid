---
id: m04-e03-t10
title: E2E Deletion Workflow
epic: m04-e03
status: pending
---

# Task: E2E Deletion Workflow

## Description
E2E test validating complete deletion workflow: create flyer, delete with confirmation, verify permanent removal from feeds and profile, verify images cleaned up.

## Scope
- Create test flyer with images
- Navigate to edit screen
- Tap delete button
- Verify confirmation dialog appears
- Cancel deletion
- Verify flyer still exists
- Delete flyer with confirmation
- Verify flyer removed from profile
- Verify flyer removed from feed
- Verify deletion is permanent (cannot be recovered)
- Run on iOS simulator
- Use Maestro E2E framework

## Success Criteria
- [ ] Test creates flyer with images
- [ ] Test navigates to edit screen
- [ ] Tapping delete shows confirmation dialog
- [ ] Canceling dialog keeps flyer
- [ ] Confirming deletion removes flyer
- [ ] Flyer removed from profile
- [ ] Flyer removed from feed
- [ ] Deletion is irreversible
- [ ] Test passes consistently
- [ ] Test runs in CI/CD pipeline
- [ ] All test code marked with `tdd_green` tag

## Test Flow
```yaml
# maestro test flow
appId: com.pockitflyer.app
---
# Setup: Create flyer with images
- tapOn: "Create Flyer"
- inputText: "Test Deletion Flyer"
- tapOn: "Add Image"
# Upload image
- tapOn: "Publish"

# Navigate to profile
- tapOn: "Profile"
- assertVisible: "Test Deletion Flyer"

# Open edit screen
- tapOn: "Test Deletion Flyer"
- tapOn: "Edit"

# Test cancel flow
- tapOn: "Delete"
- assertVisible: "Delete Flyer Permanently?"
- assertVisible: "This action cannot be undone"
- tapOn: "Cancel"

# Verify flyer still exists
- back
- assertVisible: "Test Deletion Flyer"

# Test delete flow
- tapOn: "Test Deletion Flyer"
- tapOn: "Edit"
- tapOn: "Delete"
- tapOn: "Delete"  # Confirm

# Verify removed from profile
- assertNotVisible: "Test Deletion Flyer"

# Verify removed from feed
- tapOn: "Feed"
- assertNotVisible: "Test Deletion Flyer"

# Verify cannot be recovered
- tapOn: "Profile"
- assertNotVisible: "Test Deletion Flyer"
```

## Dependencies
- M04-E03-T01 through T08 (all implementation tasks)

## Acceptance
- E2E test passes
- Deletion workflow validated end-to-end
- Permanent deletion verified
- Test documented and maintainable
