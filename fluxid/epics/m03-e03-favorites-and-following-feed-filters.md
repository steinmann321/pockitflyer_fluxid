---
id: m03-e03
title: Favorites and Following Feed Filters
milestone: m03
status: pending
---

# Epic: Favorites and Following Feed Filters

## Overview
Authenticated users can filter the home screen feed to show only their favorited flyers or only flyers from creators they follow. The "Favorites" and "Following" filters become active in the home screen filter UI, querying specialized backend endpoints that efficiently retrieve filtered flyer lists. Anonymous users see these filters as disabled/hidden. Feed performance for filtered views matches the main feed performance. This epic delivers personalized content discovery through relationship-based filtering with complete backend integration.

## Scope
- "Favorites" filter button in home screen filter bar
- "Following" filter button in home screen filter bar
- Filter UI shows active/inactive state based on authentication
- Backend API endpoint for favorites feed (flyers favorited by user)
- Backend API endpoint for following feed (flyers from followed creators)
- Efficient database queries using relationship indexes
- Feed pagination for filtered views
- Pull-to-refresh for filtered feeds
- Empty state UI for filters with no results
- Filter state persistence (remembers selected filter across sessions)
- Authentication state handling (filters disabled for anonymous users)

## Success Criteria
- [ ] "Favorites" filter button appears in home screen filter bar [Test: authenticated state, proper positioning, consistent styling]
- [ ] "Following" filter button appears in home screen filter bar [Test: authenticated state, proper positioning, consistent styling]
- [ ] Filters are disabled/hidden for anonymous users [Test: logged out state, no authentication token, visual indication]
- [ ] Tapping "Favorites" shows only favorited flyers [Test: user with favorites, empty favorites, mixed feed content]
- [ ] Tapping "Following" shows only flyers from followed creators [Test: user following creators, no follows, creators with no flyers]
- [ ] Filtered feeds display complete flyer cards (same as main feed) [Test: all card fields present, images load, distances calculated]
- [ ] Backend API efficiently queries favorites relationship [Test: 100+ favorites, query execution time <100ms, proper use of indexes]
- [ ] Backend API efficiently queries following relationship [Test: 100+ follows, query execution time <100ms, proper joins, proper indexes]
- [ ] Filtered feeds support pagination [Test: more than 20 flyers, scroll to load more, no duplicates]
- [ ] Pull-to-refresh updates filtered feeds [Test: new favorites added, unfavorite flyer, follow/unfollow creators]
- [ ] Empty state UI shows when filter returns no results [Test: favorites with no flyers, following with no flyers, helpful messaging]
- [ ] Filter selection persists across app restarts [Test: select filter, force quit, relaunch, verify filter still active]
- [ ] Switching filters updates feed immediately [Test: switch between All/Favorites/Following, correct content displayed]
- [ ] Filtered feeds load within 2 seconds on standard network [Test: 3G/4G/5G/WiFi conditions, various data volumes]
- [ ] Filter state resets to "All" when user logs out [Test: active filter, logout, verify reset to All]

## Dependencies
- Requires M03-E01 (Favorite Flyers) for favorites relationship data
- Requires M03-E02 (Follow Creators) for following relationship data
- Requires M02-E01 (User Registration and Login) for authentication context
- Requires M01-E01 (Browse Local Flyers Feed) for feed UI foundation
- External: Django REST Framework for API
- External: Flutter state management for filter state

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Filter bar design: horizontal button group with "All", "Favorites", "Following" options
- Only one filter active at a time (mutually exclusive selection)
- Backend query for favorites: JOIN user_flyer_favorites ON flyer_id WHERE user_id = current_user
- Backend query for following: JOIN user_follows ON followed_id = flyer.creator_id WHERE follower_id = current_user
- Database indexes critical for performance: see M03-E01 and M03-E02 for required indexes
- Empty state messaging: "No favorites yet" / "You're not following anyone yet" with action prompts
- Filter persistence: store last selected filter in app state (e.g., shared preferences)
- API endpoints: GET /api/flyers/?filter=favorites, GET /api/flyers/?filter=following
- Alternatively: GET /api/favorites/feed/, GET /api/following/feed/ (cleaner REST design)
- Filtered feeds should respect same sorting as main feed (recency + proximity)
- Pull-to-refresh should update relationship data AND flyer content
- Consider performance optimization: cache filter state and invalidate on favorite/follow changes
