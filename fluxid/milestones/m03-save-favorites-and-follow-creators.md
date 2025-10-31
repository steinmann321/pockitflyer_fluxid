---
id: m03
title: Users can save favorites and follow creators
status: pending
---

# Milestone: Users can save favorites and follow creators

## Deliverable
Authenticated users can favorite individual flyers to save them for later, follow creators whose content they find valuable, and filter the feed to show only favorited flyers or content from followed creators. This adds personalization and curation capabilities that improve content discovery and encourage user retention by enabling users to build their own curated experience.

## Success Criteria
- [ ] Users can tap the favorite (heart) button on any flyer card to save it (requires authentication)
- [ ] Favorite button shows visual state (filled/unfilled) indicating saved status
- [ ] Users can tap the follow button on any flyer card to follow the creator (requires authentication)
- [ ] Follow button shows visual state indicating follow status
- [ ] Users can access "Favorites" filter in the relationship filter bar
- [ ] "Favorites" filter shows only flyers the user has favorited
- [ ] Users can access "Following" filter in the relationship filter bar
- [ ] "Following" filter shows only flyers from creators the user follows
- [ ] Favorites and Following filters can be combined with category tag filters
- [ ] Favorite/follow actions are instant with visual feedback
- [ ] Backend stores user's favorites and following relationships
- [ ] Backend provides filtered feed endpoints for favorites and following
- [ ] Favorite/follow status persists across sessions
- [ ] Users can unfavorite and unfollow with same button interactions
- [ ] Anonymous users see favorite/follow buttons but get prompted to log in when tapping
- [ ] Complete UI implementation for all interaction workflows
- [ ] Full backend integration for relationship storage and filtering
- [ ] All flows are polished and production-ready
- [ ] Can be deployed independently (builds on m01 and m02)
- [ ] Requires no additional milestones to be useful

## Validation Questions
**Before marking this milestone complete, answer:**
- [x] Can a real user perform complete workflows with only this milestone? Yes - favorite flyers, follow creators, filter by favorites/following
- [x] Is it polished enough to ship publicly? Yes - complete personalization experience
- [x] Does it solve a real problem end-to-end? Yes - users can curate and personalize their content discovery
- [x] Does it include both complete UI and functional backend integration? Yes - interaction buttons UI, filter UI, backend relationship storage and queries
- [x] Can it run independently without waiting for other milestones? Yes - enhances existing browse and create workflows
- [x] Would you personally use this if it were released today? Yes - essential for building personalized feeds

## Notes
This milestone adds the personalization layer that transforms PokitFlyer from a generic discovery platform into a curated, personalized experience. By enabling favorites and following, users can build their own relationship with content and creators, increasing engagement and retention. The implementation includes:

**Frontend Components:**
- Favorite button on flyer cards with toggle interaction
- Follow button on flyer cards with toggle interaction
- Visual state indicators (filled/unfilled icons)
- "Favorites" filter chip in relationship filter bar
- "Following" filter chip in relationship filter bar
- Auth gate for anonymous users (login prompt)
- Optimistic UI updates with rollback on failure
- Loading states during interactions

**Backend Components:**
- User-Flyer favorite relationship model
- User-User following relationship model
- Favorite/unfavorite endpoints
- Follow/unfollow endpoints
- Feed filtering logic for favorites
- Feed filtering logic for following
- Relationship query optimization (indexing)
- Duplicate prevention (can't favorite/follow twice)

**User Experience Considerations:**
- Instant visual feedback on tap
- Preserved scroll position after interaction
- Clear visual distinction between favorited/unfavorited
- Clear visual distinction between following/not following
- Graceful handling of network failures
- Login prompt for anonymous users explains value

**Performance Optimizations:**
- Efficient queries for relationship filtering
- Database indexes on user_id and flyer_id
- Caching of follow/favorite counts if displayed

This milestone maps to requirements in refined-product-analysis.md sections:
- Favorites & Following (lines 202-209)
- Filter Interaction Logic (lines 130-138)
- Card Interaction Model (lines 156-165)
- Anonymous vs Authenticated Experience (lines 37-40)
