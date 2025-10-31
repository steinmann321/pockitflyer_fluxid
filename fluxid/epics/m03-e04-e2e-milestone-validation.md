---
id: m03-e04
title: End-to-End Milestone Validation
milestone: m03
status: pending
---

# Epic: End-to-End Milestone Validation

## Overview
Validates that all M03 engagement features work together seamlessly in real-world scenarios. Tests complete user workflows: authenticated user browses feed, favorites flyers, follows creators, filters by favorites/following, and sees personalized content. Ensures all interactions are polished and production-ready. Anonymous users experience graceful degradation with clear authentication prompts. This epic delivers confidence that M03 is shippable.

## Scope
- End-to-end workflow testing with Maestro E2E framework
- Complete favorite workflow: browse → favorite → filter by favorites → see favorited flyer
- Complete follow workflow: browse → follow creator → filter by following → see followed creator's flyers
- Combined workflow: multiple favorites and follows with filter switching
- Anonymous user workflow: see disabled engagement buttons with auth prompts
- Authentication boundary testing: login → access engagement features → logout → verify disabled
- Cross-session persistence: favorite/follow → restart app → verify state persisted
- Error scenario testing: network failures, server errors, rollback behaviors
- Performance validation: filtered feeds load within 2 seconds
- UI polish validation: smooth animations, responsive buttons, clear states
- Edge case testing: empty favorites, empty following, deleted flyers, deleted creators

## Success Criteria
- [ ] E2E test: Anonymous user sees disabled favorite/follow buttons [Test: fresh install, tap buttons shows auth prompt]
- [ ] E2E test: User registers → favorites flyer → filter shows favorited flyer [Test: complete registration flow, favorite action, filter activation]
- [ ] E2E test: User logs in → follows creator → filter shows followed creator's flyers [Test: complete login flow, follow action, filter activation]
- [ ] E2E test: User favorites multiple flyers → filter shows all favorited flyers [Test: 5+ favorites, verify all appear in filtered feed]
- [ ] E2E test: User follows multiple creators → filter shows all followed creators' flyers [Test: 3+ follows, verify flyers from all appear]
- [ ] E2E test: User switches between All/Favorites/Following filters [Test: correct content displayed for each, smooth transitions]
- [ ] E2E test: User unfavorites flyer → flyer disappears from favorites filter [Test: toggle favorite off, filter updates immediately]
- [ ] E2E test: User unfollows creator → creator's flyers disappear from following filter [Test: toggle follow off, filter updates immediately]
- [ ] E2E test: Favorite/follow state persists across app restarts [Test: favorite/follow, force quit, relaunch, verify states]
- [ ] E2E test: Filter selection persists across app restarts [Test: select Favorites filter, restart, verify still on Favorites]
- [ ] E2E test: User logs out → filters become disabled [Test: active filter, logout, verify filters disabled/hidden]
- [ ] E2E test: Network error during favorite → optimistic update rolls back [Test: simulate network failure, verify UI reverts]
- [ ] E2E test: Pull-to-refresh on filtered feeds updates content [Test: favorites filter, pull-to-refresh, verify updated]
- [ ] E2E test: Empty favorites shows helpful empty state [Test: new user with no favorites, navigate to Favorites filter]
- [ ] E2E test: Empty following shows helpful empty state [Test: new user not following anyone, navigate to Following filter]
- [ ] Performance validation: All filtered feeds load within 2 seconds [Test: measure load times across network conditions]
- [ ] UI validation: All buttons respond smoothly without lag [Test: rapid button tapping, state transitions, animations]
- [ ] Polish validation: All states are clear and intuitive [Test: user can understand button states without instructions]

## Dependencies
- Requires M03-E01 (Favorite Flyers) to be complete
- Requires M03-E02 (Follow Creators) to be complete
- Requires M03-E03 (Favorites and Following Feed Filters) to be complete
- Requires M02 (User Authentication) to be complete
- Requires M01 (Anonymous Discovery) to be complete
- External: Maestro E2E testing framework

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced
- [ ] Answer milestone validation questions affirmatively

## Milestone Validation Questions
**Answer these before marking M03 complete:**
- [ ] Can a real user perform complete workflows with only this milestone? (favorite flyers, follow creators, filter by favorites/following)
- [ ] Is it polished enough to ship publicly? (production-ready engagement UI)
- [ ] Does it solve a real problem end-to-end? (personalized content discovery)
- [ ] Does it include both complete UI and functional backend integration? (yes - full engagement stack)
- [ ] Can it run independently without waiting for other milestones? (yes - builds on M01 + M02)
- [ ] Would you personally use this if it were released today? (yes - valuable personalization)

## Notes
- Use Maestro E2E framework for automated testing (see CONTRIBUTORS.md for setup)
- Test scenarios should simulate real user behavior patterns
- Focus on happy paths AND edge cases (network errors, empty states, deleted content)
- Performance benchmarks should be measured on real devices, not simulators
- UI polish assessment should be qualitative (does it feel good?) not just functional
- Edge case: favorited flyer gets deleted → handle gracefully in favorites feed
- Edge case: followed creator deletes account → handle gracefully in following feed
- Consider testing with various data volumes: 1 favorite vs 100 favorites
- Test authentication boundaries carefully: anonymous → authenticated → anonymous transitions
- Ensure Maestro tests run in CI pipeline for regression prevention
- This epic validates the entire milestone - if tests fail, fix the underlying epics
