---
id: m03-e01
title: Flyer Favorites
milestone: m03
status: pending
tasks:
  - m03-e01-t01
  - m03-e01-t02
  - m03-e01-t03
---

# Epic: Flyer Favorites

## Overview
Implements complete favorite/unfavorite functionality for flyers, enabling authenticated users to save flyers for later viewing. Includes backend relationship storage, API endpoints, frontend favorite button with visual state management, optimistic UI updates, and auth gating for anonymous users.

## Scope
- Backend User-Flyer favorite relationship model
- Favorite/unfavorite API endpoints with authentication
- Database indexing for efficient queries
- Frontend favorite button component on flyer cards
- Visual state indicators (filled/unfilled heart icon)
- Optimistic UI updates with rollback on failure
- Auth gate for anonymous users (login prompt)
- Favorite state persistence across sessions

## Success Criteria
- [ ] Authenticated users can favorite any flyer with single tap [Test: various flyer types, rapid successive taps, concurrent requests]
- [ ] Favorite button shows correct visual state (filled when favorited, unfilled when not) [Test: initial load state, after favorite/unfavorite, after refresh]
- [ ] Unfavorite works with same button interaction [Test: toggle multiple times, verify database state]
- [ ] Anonymous users see login prompt when tapping favorite button [Test: prompt messaging, navigation to login, return to original flyer]
- [ ] Favorite status persists across app sessions [Test: favorite, close app, reopen, verify state]
- [ ] UI updates instantly with optimistic rendering [Test: visual feedback < 100ms, rollback on network failure]
- [ ] Backend prevents duplicate favorites for same user-flyer pair [Test: concurrent requests, multiple taps, database constraint violations]
- [ ] Favorite relationships query efficiently with proper indexing [Test: query performance with 1000+ favorites per user, N+1 query prevention]
- [ ] Network failures are handled gracefully with rollback [Test: offline mode, timeout scenarios, 500 errors]

## Tasks
- Backend favorite relationship model and endpoints (m03-e01-t01)
- Frontend favorite button component with state management (m03-e01-t02)
- Auth gate and error handling integration (m03-e01-t03)

## Dependencies
- M01 (Browse flyers) - Requires flyer cards to exist
- M02 (User authentication) - Requires auth system for authenticated favorites

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
This epic implements the simpler of the two relationship types (User-to-Flyer) first, establishing patterns for relationship management, optimistic UI, and auth gating that will be reused for following creators (e02).

**Technical Considerations:**
- Use database unique constraint on (user_id, flyer_id) to prevent duplicates
- Index on user_id for "get all favorites for user" queries
- Index on flyer_id for "get favorite count for flyer" if displayed
- Optimistic UI pattern: Update local state immediately, rollback on API failure
- Auth gate should explain value proposition before prompting login

**Performance Targets:**
- Visual feedback on tap: < 100ms
- API response time: < 300ms (p95)
- Rollback on failure: < 200ms
