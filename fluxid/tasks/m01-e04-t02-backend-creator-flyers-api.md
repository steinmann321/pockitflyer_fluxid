---
id: m01-e04-t02
epic: m01-e04
title: Create Creator Flyers Filter API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Creator Flyers Filter API Endpoint

## Objective
Extend flyer feed API to support filtering by creator ID, returning all published flyers by a specific creator.

## Acceptance Criteria
- [ ] GET `/api/flyers/?creator={user_id}` returns flyers filtered by creator
- [ ] Returns only published, valid flyers (same filtering as main feed)
- [ ] Results use same smart ranking as main feed (recency, proximity if location available)
- [ ] Pagination support (20 flyers per page, consistent with main feed)
- [ ] Database query uses index on creator_id for performance
- [ ] Returns empty array if creator has no flyers
- [ ] Returns 404 if creator user_id does not exist
- [ ] Endpoint accessible without authentication
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Filter by valid creator with multiple flyers
- Filter by creator with single flyer
- Filter by creator with no flyers (empty array)
- Non-existent creator (404)
- Pagination behavior with creator filter
- Only published/valid flyers returned (excludes expired/draft)
- Query performance with database indexes
- Response structure matches main feed format

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (extend FlyerListView with creator filter)
- `pockitflyer_backend/flyers/tests/test_views.py`
- Database migration for creator_id index (if not already exists from m01-e01-t02)

## Dependencies
- m01-e01-t02 (Flyer model with creator FK)
- m01-e01-t04 (Flyer feed API endpoint)

## Notes
- Reuse existing FlyerListView, add creator query parameter
- Same ranking algorithm as main feed (proximity + recency)
- Database index on flyers.creator_id is critical for performance
- Creator filter should work with other filters (e.g., category) in future
- Consider adding creator flyer count to user profile endpoint (future optimization)
