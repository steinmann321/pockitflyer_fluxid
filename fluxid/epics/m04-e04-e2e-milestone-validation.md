---
id: m04-e04
title: E2E Milestone Validation
milestone: m04
status: pending
---

# Epic: E2E Milestone Validation

## Overview
Comprehensive end-to-end validation of the complete flyer creation and management experience. Tests the full workflow from authenticated user creating a flyer, publishing it, seeing it in the feed, viewing it on their profile, editing all aspects, managing expiration, and permanently deleting. Validates production readiness, polish, and integration with M01-M03 features.

## Scope
- Complete creation workflow E2E test (Flyern button → publish → feed visibility)
- Complete edit workflow E2E test (profile → edit → save → verify changes)
- Complete deletion workflow E2E test (delete → confirm → verify removal)
- Expiration and reactivation workflow E2E test (expire → extend → reactivate)
- Integration with M01 feed display
- Integration with M02 authentication context
- Integration with M03 user profile
- Error handling and edge case validation
- Performance validation (image uploads, geocoding, database queries)
- Production readiness assessment (polish, UX, error messages)

## Success Criteria
- [ ] Complete creation flow works end-to-end [Test: Maestro E2E - launch app, authenticate, tap Flyern, upload images, fill fields, publish, verify in feed]
- [ ] Published flyer displays correctly in main feed with all data [Test: creator info, images, location, text, tags, dates all accurate]
- [ ] Published flyer appears on creator's profile page [Test: navigate to own profile, verify flyer listed]
- [ ] Complete edit flow works end-to-end [Test: Maestro E2E - tap flyer from profile, modify fields, save, verify changes in feed and profile]
- [ ] Image editing persists correctly [Test: add new image, remove image, reorder images, verify storage and display]
- [ ] Location editing triggers geocoding and updates coordinates [Test: change address, save, verify new coordinates and distance calculations]
- [ ] Date editing with validation works correctly [Test: extend expiration, verify validation, save, verify dates updated]
- [ ] Expiration logic removes flyers from public feeds [Test: set expiration to past, verify not in feed, still visible on own profile as expired]
- [ ] Reactivation flow works for expired flyers [Test: extend expiration date, toggle reactivation, verify flyer reappears in feed]
- [ ] Complete deletion flow works end-to-end [Test: Maestro E2E - tap delete, confirm warning, verify removal from feed and profile]
- [ ] Hard delete is permanent and irreversible [Test: verify database record deleted, images deleted from storage, cannot recover]
- [ ] Integration with M01 feed works seamlessly [Test: created/edited/deleted flyers update feed correctly, ranking works]
- [ ] Integration with M02 authentication works seamlessly [Test: only authenticated users can create/edit/delete, auth required for Flyern button]
- [ ] Integration with M03 profile works seamlessly [Test: flyers appear on creator profile, profile edits reflect correctly]
- [ ] Error handling is production-ready [Test: network failures, geocoding failures, image upload failures, validation errors - all show clear user feedback]
- [ ] Performance meets requirements [Test: image upload <5s, feed update <2s, geocoding <3s, smooth UI transitions]
- [ ] UI is polished and consumer-grade [Test: visual design, loading states, error messages, success confirmations, intuitive workflows]

## Validation Questions
**Answer these questions before marking milestone complete:**
- [ ] Can a real user perform complete workflows with only this milestone? (Yes - create, publish, edit, delete flyers end-to-end)
- [ ] Is it polished enough to ship publicly? (Yes - production-ready creation and management UI)
- [ ] Does it solve a real problem end-to-end? (Yes - digital flyer creation and distribution)
- [ ] Does it include both complete UI and functional backend integration? (Yes - full creation stack with geocoding and image storage)
- [ ] Can it run independently without waiting for other milestones? (Yes - builds on M01-M03 which are complete)
- [ ] Would you personally use this if it were released today? (Yes - complete platform for creating and discovering local flyers)

## Dependencies
- M04-E01 (Create and Publish Flyers) for creation functionality
- M04-E02 (View and Edit Own Flyers) for editing functionality
- M04-E03 (Flyer Expiration and Deletion) for expiration and deletion functionality
- M01 (Anonymous Discovery) for feed integration
- M02 (User Authentication) for auth context
- M03 (Authenticated Engagement) for profile integration

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] All validation questions answered "Yes"
- [ ] Epic validates milestone deliverability
- [ ] No regressions or breaking changes introduced
- [ ] Maestro E2E tests pass for all workflows
- [ ] Performance benchmarks met
- [ ] Production readiness confirmed

## Notes
- This epic is the final validation gate before marking M04 complete
- Use Maestro for E2E testing of complete workflows
- Test with realistic data (various image sizes, long text, international addresses)
- Validate error scenarios thoroughly (network failures, service outages, invalid inputs)
- Confirm all edge cases from M04-E01, M04-E02, M04-E03 work in integrated environment
- After M04, the platform is feature-complete for core use case (create and discover local flyers)
- Consider real-world scenarios: slow network, geocoding failures, concurrent edits, storage limits
- Production readiness means consumer-grade quality, not just functional correctness
