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
- [ ] All tests marked with `@pytest.mark.tdd_green` (backend) or `tags: ['tdd_green']` (frontend) after passing

## Test Coverage Requirements
- Backend query performance tests (measure execution time)
- Database index existence tests

## Dependencies
- m01-e01-t01, m01-e01-t02 (Models must exist)
- m01-e01-t04 (API must exist)
- m01-e01-t08 (Frontend screen must exist)

## Notes
- Performance baseline: 100 flyers in database
- Lazy loading: only load images when FlyerCard is in viewport
- This task is about optimization, not new features
