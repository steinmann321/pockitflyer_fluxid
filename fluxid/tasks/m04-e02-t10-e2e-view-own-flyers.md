---
id: m04-e02-t10
epic: m04-e02
title: E2E Test - View Own Flyers on Profile
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - View Own Flyers on Profile

## Objective
Create Maestro end-to-end test validating that authenticated users can view their published flyers on their profile page.

## Acceptance Criteria
- [ ] Test creates test user and authenticates
- [ ] Test creates 3 test flyers with different statuses (active, expired, scheduled)
- [ ] Test navigates to user's own profile
- [ ] Test verifies flyers list is visible
- [ ] Test verifies all 3 flyers appear in list
- [ ] Test verifies status badges display correctly
- [ ] Test verifies flyer details (title, dates) display correctly
- [ ] Test verifies empty state when no flyers exist
- [ ] Test tagged with `tdd_green` after passing

## Test Coverage Requirements
- User with 0 flyers sees empty state
- User with 1 flyer sees single item
- User with multiple flyers sees all items
- Active flyer shows green "Active" badge
- Expired flyer shows red "Expired" badge
- Scheduled flyer shows blue "Scheduled" badge
- Flyers ordered by publication date (newest first)
- Pull-to-refresh updates flyer list

## Files to Modify/Create
- `maestro/flows/m04-e02-view-own-flyers.yaml`
- `maestro/test-data/m04-e02-setup.sh` (test data creation script)

## Dependencies
- M04-E02-T04 (Profile flyers list widget)
- M04-E02-T07 (Profile integration)
- M04-E01 (Flyer creation API for test data)
- E2E test infrastructure from M01-E05

## Notes
- Use Maestro's backend test data setup for flyer creation
- Test different flyer states by manipulating dates
- Verify visual elements like status badge colors
- Consider testing pagination if many flyers
- Ensure test cleanup removes test flyers after execution
