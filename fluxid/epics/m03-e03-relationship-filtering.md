---
id: m03-e03
title: Relationship Filtering
milestone: m03
status: pending
tasks:
  - m03-e03-t01
  - m03-e03-t02
  - m03-e03-t03
---

# Epic: Relationship Filtering

## Overview
Implements personalized feed filtering based on user relationships, adding "Favorites" and "Following" filter chips to the relationship filter bar. Users can filter the feed to show only favorited flyers or content from followed creators, with filters combinable with existing category tag filters. Includes backend filtered feed endpoints and frontend filter UI integration.

## Scope
- Backend filtered feed endpoints (favorites, following)
- Efficient database queries with relationship joins
- Frontend "Favorites" filter chip component
- Frontend "Following" filter chip component
- Integration with existing relationship filter bar (from m01)
- Filter combination logic (relationship + category tags)
- Empty states for filtered views
- Loading states during filter changes
- Scroll position preservation after filtering

## Success Criteria
- [ ] "Favorites" filter chip appears in relationship filter bar [Test: authenticated users see chip, anonymous users see chip but get auth prompt on tap]
- [ ] Tapping "Favorites" filter shows only flyers user has favorited [Test: various favorite counts including zero, verify database queries use relationship join]
- [ ] "Following" filter chip appears in relationship filter bar [Test: authenticated users see chip, anonymous users see auth prompt]
- [ ] Tapping "Following" filter shows only flyers from creators user follows [Test: various following counts including zero, verify queries use relationship join]
- [ ] Relationship filters can be combined with category tag filters [Test: "Favorites + Events" shows only favorited event flyers, verify AND logic]
- [ ] Filter chips show active/inactive visual states [Test: toggle states, multiple filters active simultaneously]
- [ ] Empty states display when no results match filters [Test: favorites filter with no favorites, following filter with no followed creators]
- [ ] Feed updates instantly when filters change [Test: filter toggle responsiveness, loading states shown during fetch]
- [ ] Scroll position is preserved after filtering [Test: scroll down, apply filter, verify position maintenance]
- [ ] Backend queries are optimized for relationship filtering [Test: query performance with 1000+ relationships, proper indexing, N+1 prevention]
- [ ] Filters persist across navigation but reset on app restart [Test: apply filter, navigate away, return, verify filter state; restart app, verify reset]

## Tasks
- Backend filtered feed endpoints with relationship queries (m03-e03-t01)
- Frontend relationship filter chips and UI integration (m03-e03-t02)
- Filter combination logic and state management (m03-e03-t03)

## Dependencies
- M01 (Browse flyers) - Requires existing feed and category tag filter infrastructure
- M02 (User authentication) - Requires auth context for determining filter visibility and behavior
- M03-E01 (Flyer favorites) - Requires favorite relationships to exist for filtering
- M03-E02 (Creator following) - Requires following relationships to exist for filtering

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
This epic brings together the relationship types from e01 and e02 to create the personalized filtering experience that is the core value proposition of m03. The filter implementation should integrate seamlessly with the existing category tag filter system from m01.

**Technical Considerations:**
- Backend endpoints: `/api/feed/?relationship=favorites`, `/api/feed/?relationship=following`
- Combine with category filters: `/api/feed/?relationship=favorites&tags=events,food`
- Use JOIN queries efficiently: `SELECT flyers.* FROM flyers JOIN favorites ON ... WHERE favorites.user_id = ?`
- Cache relationship data in frontend state to avoid redundant queries
- Show skeleton loading state during filter fetch
- Preserve scroll position using Flutter scroll controller

**Performance Targets:**
- Filter change to first content rendered: < 500ms
- Query response time for filtered feeds: < 400ms (p95)
- UI responsiveness during filter toggle: < 100ms

**Empty State Messaging:**
- Favorites filter, no favorites: "You haven't favorited any flyers yet. Tap the heart icon on flyers you want to save."
- Following filter, no follows: "You're not following any creators yet. Tap the follow button on flyers from creators you want to follow."
- Combined filters, no results: "No flyers match your selected filters. Try adjusting your filter selection."

**Filter Combination Logic:**
- Category tags are OR within categories (Events OR Food)
- Relationship filters are exclusive (Favorites OR Following, not both)
- Relationship + Category is AND (Favorites AND (Events OR Food))
