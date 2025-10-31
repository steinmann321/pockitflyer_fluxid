---
id: m04-e02-t11
epic: m04-e02
title: E2E Test - Complete Flyer Edit Workflow
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Flyer Edit Workflow

## Objective
Create Maestro end-to-end test validating the complete workflow of editing an existing flyer with all field types.

## Acceptance Criteria
- [ ] Test creates authenticated user and test flyer
- [ ] Test navigates to profile and taps flyer card
- [ ] Test verifies navigation to edit screen
- [ ] Test verifies all fields pre-populated with existing data
- [ ] Test modifies title text
- [ ] Test modifies caption text
- [ ] Test adds new category tag
- [ ] Test removes existing category tag
- [ ] Test changes location address
- [ ] Test changes expiration date
- [ ] Test taps save button
- [ ] Test verifies loading state during save
- [ ] Test verifies success navigation back to profile
- [ ] Test verifies changes persisted in backend
- [ ] Test tagged with `tdd_green` after passing

## Test Coverage Requirements
- Navigation from profile to edit screen
- All fields pre-populated correctly
- Text field modifications save correctly
- Category tag additions and removals save correctly
- Location address change triggers geocoding on backend
- Date changes save correctly and respect validation
- Save button disabled during operation
- Success feedback and navigation
- Changes reflected in profile flyers list
- Changes reflected in main feed

## Files to Modify/Create
- `maestro/flows/m04-e02-edit-flyer-workflow.yaml`
- `maestro/test-data/m04-e02-edit-setup.sh`

## Dependencies
- M04-E02-T05 (Flyer edit screen)
- M04-E02-T02 (Backend update API)
- M04-E02-T08 (Navigation routing)
- E2E test infrastructure from M01-E05

## Notes
- Verify geocoding happens server-side (no client-side indicator needed)
- Test should verify changes in both profile and main feed
- Consider testing concurrent edit scenario in separate test
- Ensure test cleanup removes test data
- Use Maestro assertions to verify UI state changes
