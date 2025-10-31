---
id: m03-e02
title: Follow Creators
milestone: m03
status: pending
---

# Epic: Follow Creators

## Overview
Authenticated users can follow and unfollow creators using an interactive follow button on flyer cards and creator profile pages. The button shows correct state (following/not following) with real-time updates when toggled. Follow actions persist in the backend with a many-to-many relationship model. Anonymous users see a disabled follow button that prompts authentication. This epic delivers complete follow functionality with full backend integration including Django REST API endpoints and database relationship model.

## Scope
- Follow button UI on flyer cards and profile pages (button with following/follow states)
- Follow/unfollow button interactions with optimistic UI updates
- Backend API endpoints for creating and deleting follows
- Database many-to-many relationship model (user-user follows)
- Authentication state handling (authenticated vs anonymous)
- Button state persistence across sessions
- Real-time button state synchronization with backend
- Error handling for failed follow operations
- Disabled state UI for anonymous users with authentication prompt
- Database indexing for efficient following queries
- Prevention of self-follow (cannot follow yourself)

## Success Criteria
- [ ] Follow button appears on flyer cards (near creator info) [Test: feed view, detail view, various card layouts]
- [ ] Follow button appears on creator profile pages [Test: profile header, various profile states]
- [ ] Button shows correct initial state (following or not) [Test: previously followed creators, new creators, state after app restart]
- [ ] Tapping button toggles follow state immediately (optimistic update) [Test: tap follow, tap unfollow, rapid tapping, network delays]
- [ ] Backend API creates follow relationship on follow action [Test: POST endpoint, authentication required, duplicate follow handling]
- [ ] Backend API deletes follow relationship on unfollow action [Test: DELETE endpoint, authentication required, non-existent follow handling]
- [ ] Button state syncs with backend after network response [Test: success response, error response, rollback on failure]
- [ ] Follow state persists across app restarts [Test: follow creator, force quit, relaunch, verify state]
- [ ] Anonymous users see disabled button with authentication prompt [Test: tap button shows login sheet, no backend call made]
- [ ] Users cannot follow themselves [Test: own profile page shows no follow button, API rejects self-follow]
- [ ] Database many-to-many model handles follows efficiently [Test: user following 100+ creators, creator with 100+ followers, query performance]
- [ ] Database indexes optimize following queries [Test: query all followed creators for user, check if following creator, performance benchmarks]
- [ ] Error handling rolls back optimistic updates on failure [Test: network error, server error, 401 unauthorized, verify UI rollback]
- [ ] Button animations are smooth and responsive [Test: tap feedback, state transitions, no UI lag]

## Dependencies
- Requires M02-E01 (User Registration and Login) for authentication context
- Requires M02-E02 (User Profile Management) for creator profile pages
- Requires M01-E01 (Browse Local Flyers Feed) for flyer cards display
- External: Django REST Framework for API
- External: Flutter state management for button state

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Follow button uses text labels: "Follow" (not following) → "Following" (following)
- Button styling: outlined when not following, filled when following
- Optimistic updates provide instant feedback - rollback if backend fails
- Backend must enforce one follow per user-creator pair (unique constraint)
- Backend must prevent self-follows (follower_id != followed_id validation)
- Consider edge case: user follows deleted creator (handle gracefully)
- Button tap area should be large enough for comfortable interaction
- State management must handle concurrent follow operations gracefully
- API endpoints: POST /api/follows/ (create), DELETE /api/follows/{id}/ (delete)
- Database table: user_follows (follower_id, followed_id, created_at)
- Indexes needed: composite index on (follower_id, followed_id), index on follower_id for user's following list
- Follow button on flyer cards should be positioned near creator name/avatar
