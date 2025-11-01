---
id: m01-e01-t04
epic: m01-e01
title: Implement Feed API Endpoint
status: completed
priority: high
tdd_phase: green
---

# Task: Implement Feed API Endpoint

## Objective
Create Django REST API endpoint to retrieve smart-ranked flyer feed based on user location.

## Acceptance Criteria
- [x] GET `/api/v1/flyers/feed/` endpoint
- [x] Query parameters: `lat` (required), `lng` (required), `page` (optional), `page_size` (optional, max 50)
- [x] Returns paginated list of flyers with complete data
- [x] Smart ranking: ORDER BY created_at DESC, then distance ASC (PostgreSQL/PostGIS in production, simple for M01)
- [x] Each flyer includes: id, title, description, creator (id, username, profile_picture), images (array), location (address, lat, lng, distance_km), validity (valid_from, valid_until, is_valid)
- [x] Distance calculation using Haversine formula
- [x] Filters: only returns valid flyers (current datetime within validity period)
- [x] Response time: <500ms for 100 flyers (with proper indexing)
- [x] Authentication: NOT required (anonymous access)
- [x] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Successful feed retrieval with various user locations
- Pagination behavior (page, page_size)
- Distance calculation accuracy (various user-flyer distances)
- Smart ranking order (newest first, then closest)
- Invalid/expired flyers are filtered out
- Missing/invalid query parameters handling
- Empty feed scenario
- Performance with 100+ flyers
- Response data structure matches specification

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (FeedViewSet)
- `pockitflyer_backend/flyers/serializers.py` (FlyerFeedSerializer, CreatorSerializer)
- `pockitflyer_backend/flyers/urls.py`
- `pockitflyer_backend/flyers/tests/test_views/test_feed.py`

## Dependencies
- m01-e01-t01 (User model)
- m01-e01-t02 (Flyer model)

## Notes
- Distance calculation: Haversine formula (simple implementation for M01, PostGIS later)
- Default page_size: 20
- Max page_size: 50 (prevents excessive data transfer)
- Returns only flyers where is_valid=True
- Creator profile_picture URL is absolute (for frontend display)
