---
id: m03-e01
title: Favorite Flyers
milestone: m03
status: pending
---

# Epic: Favorite Flyers

## Overview
Authenticated users can favorite and unfavorite flyers using an interactive favorite button on flyer cards. The button shows correct state (favorited/not favorited) with real-time updates when toggled. Favorite actions persist in the backend with a many-to-many relationship model. Anonymous users see a disabled favorite button that prompts authentication. This epic delivers complete favorite functionality with full backend integration including Django REST API endpoints and database relationship model.

## Scope
- Favorite button UI on flyer cards (heart icon with filled/unfilled states)
- Favorite/unfavorite button interactions with optimistic UI updates
- Backend API endpoints for creating and deleting favorites
- Database many-to-many relationship model (user-flyer favorites)
- Authentication state handling (authenticated vs anonymous)
- Button state persistence across sessions
- Real-time button state synchronization with backend
- Error handling for failed favorite operations
- Disabled state UI for anonymous users with authentication prompt
- Database indexing for efficient favorite queries

## Success Criteria
- [ ] Favorite button appears on all flyer cards [Test: feed view, detail view, various card layouts]
- [ ] Button shows correct initial state (favorited or not) [Test: previously favorited flyers, new flyers, state after app restart]
- [ ] Tapping button toggles favorite state immediately (optimistic update) [Test: tap favorite, tap unfavorite, rapid tapping, network delays]
- [ ] Backend API creates favorite relationship on favorite action [Test: POST endpoint, authentication required, duplicate favorite handling]
- [ ] Backend API deletes favorite relationship on unfavorite action [Test: DELETE endpoint, authentication required, non-existent favorite handling]
- [ ] Button state syncs with backend after network response [Test: success response, error response, rollback on failure]
- [ ] Favorite state persists across app restarts [Test: favorite flyer, force quit, relaunch, verify state]
- [ ] Anonymous users see disabled button with authentication prompt [Test: tap button shows login sheet, no backend call made]
- [ ] Database many-to-many model handles favorites efficiently [Test: user with 100+ favorites, flyer with 100+ favorites, query performance]
- [ ] Database indexes optimize favorite queries [Test: query all favorites for user, check if flyer is favorited, performance benchmarks]
- [ ] Error handling rolls back optimistic updates on failure [Test: network error, server error, 401 unauthorized, verify UI rollback]
- [ ] Button animations are smooth and responsive [Test: tap feedback, state transitions, no UI lag]

## Dependencies
- Requires M02-E01 (User Registration and Login) for authentication context
- Requires M01-E01 (Browse Local Flyers Feed) for flyer cards display
- External: Django REST Framework for API
- External: Flutter state management for button state

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Favorite button uses heart icon (empty heart = not favorited, filled heart = favorited)
- Optimistic updates provide instant feedback - rollback if backend fails
- Backend must enforce one favorite per user-flyer pair (unique constraint)
- Consider edge case: user favorites deleted flyer (handle gracefully)
- Button tap area should be large enough for comfortable interaction (44x44pt minimum)
- State management must handle concurrent favorite operations gracefully
- API endpoints: POST /api/favorites/ (create), DELETE /api/favorites/{id}/ (delete)
- Database table: user_flyer_favorites (user_id, flyer_id, created_at)
- Indexes needed: composite index on (user_id, flyer_id), index on user_id for user favorites query
