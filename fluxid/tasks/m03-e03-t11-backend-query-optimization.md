---
id: m03-e03-t11
epic: m03-e03
title: Backend Query Performance Optimization
status: pending
priority: high
tdd_phase: red
---

# Task: Backend Query Performance Optimization

## Objective
Optimize database queries for filtered feeds to achieve <100ms query execution time with 100+ relationships. Use database profiling to identify bottlenecks and add indexes as needed.

## Acceptance Criteria
- [ ] Favorites feed query executes in <100ms with 100+ favorites
- [ ] Following feed query executes in <100ms with 100+ follows
- [ ] Database indexes exist on all queried fields (user_id, flyer_id, created_at)
- [ ] Composite indexes used for multi-field queries
- [ ] Query plan analysis shows efficient index usage (no full table scans)
- [ ] select_related() and prefetch_related() used to reduce N+1 queries
- [ ] Performance tests validate <100ms query time
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Favorites feed query performance test (100+ favorites, measure time)
- Following feed query performance test (100+ follows, measure time)
- Database index existence verification tests
- Query plan analysis tests (EXPLAIN output)
- N+1 query prevention tests (count database queries)
- Pagination performance tests (no slowdown with large offsets)

## Files to Modify/Create
- `pockitflyer_backend/flyers/tests/test_feed_performance.py` (create performance tests)
- `pockitflyer_backend/flyers/migrations/000X_add_feed_filter_indexes.py` (add indexes if needed)

## Dependencies
- m03-e03-t01 (Favorites feed API)
- m03-e03-t02 (Following feed API)
- m03-e01-t01 (Favorite model with indexes)
- m03-e02-t01 (Follow model with indexes)

## Notes
- Use Django Debug Toolbar or django-silk for query profiling in development
- Use pytest-benchmark for performance testing
- Critical indexes: (user_id, created_at), (follower_id, created_at), (flyer_id, created_at)
- Consider using database-level query caching if supported (Redis, Memcached)
- Profile queries with realistic data volumes (1000+ flyers, 100+ relationships)
- Document expected query performance in test docstrings
