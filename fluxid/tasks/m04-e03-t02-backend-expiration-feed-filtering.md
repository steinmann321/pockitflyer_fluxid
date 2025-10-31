---
id: m04-e03-t02
title: Backend Expiration Feed Filtering
epic: m04-e03
status: pending
---

# Task: Backend Expiration Feed Filtering

## Description
Update feed API endpoints to filter out inactive/expired flyers from public feeds while still showing them in user's profile view with expired status.

## Scope
- Update feed list API to filter `is_active=True`
- Update filtered feeds (category, favorites, following) to filter `is_active=True`
- Update user profile flyers API to include inactive flyers with status field
- Add `status` field to serializer response: "active" | "expired"
- Add query optimization with select_related/prefetch_related
- Performance test with 1000+ flyers

## Success Criteria
- [ ] Public feed excludes inactive flyers
- [ ] Category/favorites/following feeds exclude inactive flyers
- [ ] User's own profile includes inactive flyers
- [ ] Serializer includes `status` field with correct value
- [ ] Query performance acceptable with 1000+ flyers (<200ms)
- [ ] Database indexes utilized (verify with EXPLAIN)
- [ ] All tests pass with `tdd_green` marker

## Test Cases
```python
@pytest.mark.tdd_red
def test_feed_api_excludes_inactive_flyers():
    """GET /api/flyers/ excludes is_active=False flyers"""

@pytest.mark.tdd_red
def test_category_feed_excludes_inactive():
    """GET /api/flyers/?category=X excludes inactive flyers"""

@pytest.mark.tdd_red
def test_favorites_feed_excludes_inactive():
    """GET /api/flyers/?filter=favorites excludes inactive flyers"""

@pytest.mark.tdd_red
def test_following_feed_excludes_inactive():
    """GET /api/flyers/?filter=following excludes inactive flyers"""

@pytest.mark.tdd_red
def test_user_profile_flyers_includes_inactive():
    """GET /api/users/{id}/flyers/ includes inactive flyers"""

@pytest.mark.tdd_red
def test_flyer_serializer_status_active():
    """Serializer shows status='active' for active flyers"""

@pytest.mark.tdd_red
def test_flyer_serializer_status_expired():
    """Serializer shows status='expired' for expired flyers"""

@pytest.mark.tdd_red
def test_feed_query_performance_1000_flyers():
    """Feed query with 1000+ flyers completes in <200ms"""
```

## Dependencies
- M04-E03-T01 (Backend Expiration Model Logic)
- Existing feed APIs from M01-E01

## Acceptance
- All tests marked `tdd_green`
- Feed API responses correct
- No performance regressions
