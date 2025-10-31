---
id: m03
title: Authenticated Engagement - Favorites and Following
status: pending
---

# Milestone: Authenticated Engagement - Favorites and Following

## Deliverable
Authenticated users can favorite flyers and follow creators to personalize their discovery experience. The "Favorites" and "Following" filters on the home screen become active, allowing users to view only their favorited flyers or flyers from creators they follow. Favorite and follow actions are integrated into flyer cards with real-time state updates. All engagement data is persisted in the backend with proper relationship models.

## Success Criteria
- [ ] Authenticated users can favorite/unfavorite flyers using the favorite button on flyer cards - UI button with backend API integration and state management
- [ ] Authenticated users can follow/unfollow creators using the follow button on flyer cards and profile pages - UI button with backend API integration
- [ ] "Favorites" filter on home screen shows only flyers the user has favorited - filter UI queries backend favorites relationship API
- [ ] "Following" filter on home screen shows only flyers from creators the user follows - filter UI queries backend following relationship API
- [ ] Favorite and follow buttons show correct state (favorited/not favorited, following/not following) - UI reflects current backend relationship state
- [ ] Button states update in real-time when user toggles favorites or follows - optimistic UI updates with backend sync
- [ ] Anonymous users cannot access favorite or follow functionality - UI buttons show authentication required state
- [ ] "Favorites" and "Following" filters are disabled/hidden for anonymous users - UI adapts based on authentication status
- [ ] Complete UI implementation for engagement workflows - polished favorite/follow interactions
- [ ] Full backend relationship models (user-flyer favorites, user-user follows) - database tables with proper foreign keys and indexes
- [ ] Backend APIs for creating/deleting favorites and follows - Django REST endpoints with authentication required
- [ ] Backend APIs for querying favorites and following feeds - efficient filtered queries with pagination
- [ ] All flows are polished and production-ready - smooth, responsive engagement features
- [ ] Can be deployed on top of M01 + M02 - requires authentication foundation
- [ ] Delivers immediate personalization value to authenticated users

## Validation Questions
**Before marking this milestone complete, answer:**
- [ ] Can a real user perform complete workflows with only this milestone? (favorite flyers, follow creators, filter by favorites/following)
- [ ] Is it polished enough to ship publicly? (production-ready engagement UI)
- [ ] Does it solve a real problem end-to-end? (personalized content discovery)
- [ ] Does it include both complete UI and functional backend integration? (yes - full engagement stack)
- [ ] Can it run independently without waiting for other milestones? (yes - builds on M01 + M02)
- [ ] Would you personally use this if it were released today? (yes - valuable personalization)

## Notes
- Requires M01 (Anonymous Discovery) for flyer browsing foundation
- Requires M02 (User Authentication) for authenticated user context
- Favorites and follows are many-to-many relationships in database
- Backend must efficiently handle relationship queries for feed filtering
- UI must gracefully handle authentication state (anonymous vs authenticated)
- Favorite/follow state must persist across sessions
- Consider edge cases: favoriting deleted flyers, following deleted users
- Performance: favorites and following feeds should load as fast as main feed
