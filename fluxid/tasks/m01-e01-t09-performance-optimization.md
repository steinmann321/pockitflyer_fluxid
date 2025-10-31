---
id: m01-e01-t09
epic: m01-e01
title: Performance Optimization and Database Indexing
status: pending
priority: medium
tdd_phase: red
---

# Task: Performance Optimization and Database Indexing

## Objective
Optimize backend query performance and ensure feed loads within 2 seconds under various conditions.

## Acceptance Criteria
- [ ] Database indexes verified on:
  - Flyer: (latitude, longitude) - compound index for proximity queries
  - Flyer: created_at - for recency sorting
  - Flyer: (valid_from, valid_until) - for validity filtering
  - Flyer: creator_id - foreign key queries
  - User: username, email - lookups
- [ ] Query optimization:
  - Select only required fields (no SELECT *)
  - Use select_related/prefetch_related for creator and images
  - Pagination limits max results per request
- [ ] Backend response time: <500ms for 100 flyers (measured via tests)
- [ ] Frontend feed load: <2 seconds on 4G network (measured via E2E tests)
- [ ] Image optimization:
  - Images compressed and resized on upload
  - Serve images at appropriate resolution for mobile
  - Lazy loading for off-screen images
- [ ] All tests marked with `@pytest.mark.tdd_green` (backend) or `tags: ['tdd_green']` (frontend) after passing

## Test Coverage Requirements
- Backend query performance tests (measure execution time)
- Database index existence tests
- API response time under load (100+ flyers)
- Frontend image loading performance
- Network condition simulations (3G/4G/5G)
- Memory usage profiling during scroll

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (verify/add indexes)
- `pockitflyer_backend/flyers/views.py` (optimize queries)
- `pockitflyer_backend/flyers/tests/test_performance.py`
- `pockitflyer_app/lib/widgets/flyer_card.dart` (lazy loading)
- `pockitflyer_app/test/performance/feed_load_performance_test.dart`

## Dependencies
- m01-e01-t01, m01-e01-t02 (Models must exist)
- m01-e01-t04 (API must exist)
- m01-e01-t08 (Frontend screen must exist)

## Notes
- Performance baseline: 100 flyers in database
- Use Django Debug Toolbar to profile queries in development
- Consider adding database query logging for slow queries (>100ms)
- Image compression: JPEG quality 85%, max dimensions 1200x1200px
- Lazy loading: only load images when FlyerCard is in viewport
- This task is about optimization, not new features
