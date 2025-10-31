---
id: m03-e02
title: Creator Following
milestone: m03
status: pending
tasks:
  - m03-e02-t01
  - m03-e02-t02
  - m03-e02-t03
---

# Epic: Creator Following

## Overview
Implements complete follow/unfollow functionality for creators, enabling authenticated users to follow creators whose content they find valuable. Includes backend User-User relationship storage, API endpoints, frontend follow button with visual state management, optimistic UI updates, and auth gating for anonymous users. Reuses patterns established in favorites epic (e01).

## Scope
- Backend User-User following relationship model
- Follow/unfollow API endpoints with authentication
- Database indexing for efficient queries
- Frontend follow button component on flyer cards
- Visual state indicators (follow/following state)
- Optimistic UI updates with rollback on failure
- Auth gate for anonymous users (login prompt)
- Follow status persistence across sessions

## Success Criteria
- [ ] Authenticated users can follow any creator with single tap [Test: various creators, rapid successive taps, concurrent requests, self-follow prevention]
- [ ] Follow button shows correct visual state (following vs not following) [Test: initial load state, after follow/unfollow, after refresh]
- [ ] Unfollow works with same button interaction [Test: toggle multiple times, verify database state]
- [ ] Anonymous users see login prompt when tapping follow button [Test: prompt messaging, navigation to login, return to original flyer]
- [ ] Follow status persists across app sessions [Test: follow, close app, reopen, verify state]
- [ ] UI updates instantly with optimistic rendering [Test: visual feedback < 100ms, rollback on network failure]
- [ ] Backend prevents duplicate follows for same follower-followee pair [Test: concurrent requests, multiple taps, database constraint violations]
- [ ] Backend prevents users from following themselves [Test: attempt self-follow, verify error handling]
- [ ] Following relationships query efficiently with proper indexing [Test: query performance with 1000+ follows per user, N+1 query prevention]
- [ ] Network failures are handled gracefully with rollback [Test: offline mode, timeout scenarios, 500 errors]

## Tasks
- Backend following relationship model and endpoints (m03-e02-t01)
- Frontend follow button component with state management (m03-e02-t02)
- Auth gate and error handling integration (m03-e02-t03)

## Dependencies
- M01 (Browse flyers) - Requires flyer cards with creator information
- M02 (User authentication) - Requires auth system for authenticated follows
- M03-E01 (Flyer favorites) - Reuses patterns for relationship management and optimistic UI

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
This epic builds on the relationship management patterns established in e01 (favorites), adapting them for User-User relationships. The implementation should reuse components and patterns where possible.

**Technical Considerations:**
- Use database unique constraint on (follower_id, followee_id) to prevent duplicates
- Add validation to prevent self-follows (follower_id != followee_id)
- Index on follower_id for "get all users I'm following" queries
- Index on followee_id for "get all my followers" queries (if needed)
- Reuse optimistic UI pattern from favorites
- Reuse auth gate component from favorites

**Performance Targets:**
- Visual feedback on tap: < 100ms
- API response time: < 300ms (p95)
- Rollback on failure: < 200ms

**Differences from Favorites:**
- User-User relationship vs User-Flyer
- Self-follow prevention required
- May need bidirectional indexing for follower/followee queries
