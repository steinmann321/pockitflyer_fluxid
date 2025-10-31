---
id: m03-e02-t11
epic: m03-e02
title: Follow Performance Optimization
status: pending
priority: low
tdd_phase: red
---

# Task: Follow Performance Optimization

## Objective
Optimize follow-related database queries and frontend rendering for performance. Ensure queries use indexes efficiently, minimize N+1 queries, and frontend minimizes unnecessary rebuilds.

## Acceptance Criteria
- [ ] Database queries for "is following" use composite index (follower_id, followed_id)
- [ ] Feed API uses select_related/prefetch_related to include follow status in single query
- [ ] Frontend FollowButton uses memo/const to prevent unnecessary rebuilds
- [ ] State management minimizes listener notifications (only on actual state change)
- [ ] Performance benchmarks: query for 100+ follows completes <50ms
- [ ] Feed loading with 20 flyers (each checking follow status) completes <200ms
- [ ] All tests marked with `@pytest.mark.tdd_green` (backend) and `tags: ['tdd_green']` (frontend) after passing

## Test Coverage Requirements
- Backend: Query plan analysis shows index usage for follow status lookup
- Backend: N+1 query detection (feed endpoint should not have N+1 for follow status)
- Backend: Performance benchmark test for 100+ follows query
- Frontend: Widget rebuild count test (button should not rebuild on unrelated state changes)
- Frontend: State update frequency test (only updates when follow set actually changes)

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (optimize feed follow status queries)
- `pockitflyer_backend/users/tests/test_performance.py` (create performance tests)
- `pockitflyer_app/lib/widgets/follow_button.dart` (add const/memo optimizations)
- `pockitflyer_app/lib/providers/follow_provider.dart` (optimize state notifications)
- `pockitflyer_app/test/performance/follow_performance_test.dart` (create performance tests)

## Dependencies
- m03-e02-t01 through m03-e02-t07 (all core follow functionality complete)

## Notes
- Use Django Debug Toolbar or logging to identify N+1 queries
- Database EXPLAIN ANALYZE useful for verifying index usage
- Frontend profiling tools (Flutter DevTools) for widget rebuild detection
- Consider caching follow status for frequently viewed users
- Benchmark on realistic data volumes (100+ creators, 1000+ follows)
