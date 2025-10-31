---
id: m01-e02-t02
epic: m01-e02
title: Add Database Indexes for Efficient Filtering
status: pending
priority: high
tdd_phase: red
---

# Task: Add Database Indexes for Efficient Filtering

## Objective
Create compound database indexes on the Flyer model to optimize filtered query performance, ensuring sub-500ms response times for all filter combinations.

## Acceptance Criteria
- [ ] Compound index on (category, latitude, longitude, valid_until)
- [ ] Index on (latitude, longitude) for proximity queries
- [ ] Index on valid_until for date range filtering
- [ ] Text search index on title field (if database supports)
- [ ] Text search index on description field (if database supports)
- [ ] Migration created and tested
- [ ] Performance test shows < 500ms query time with 1000+ flyers
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Verify indexes exist in database schema
- Performance benchmark: filtered queries with 1000+ flyers
- Performance benchmark: Near Me queries with various distances
- Performance benchmark: search queries with various terms
- Performance benchmark: combined filter queries
- Compare query time with and without indexes

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (add Meta indexes)
- `pockitflyer_backend/flyers/migrations/000X_add_filter_indexes.py` (auto-generated)
- `pockitflyer_backend/flyers/tests/test_performance.py` (new file for performance tests)

## Dependencies
- Task m01-e01-t02 (Flyer model must exist)

## Notes
- SQLite has limited full-text search support; use standard indexes for M01
- Consider database-specific optimizations (GiST indexes for PostgreSQL in future)
- Performance tests should create test data with factories (1000+ flyers)
- Use Django's `connection.queries` to measure actual query execution
- Document index strategy in code comments
