---
id: m01-e05-t03
epic: m01-e05
title: E2E Test - Complete Filter/Search Workflow (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Filter/Search Workflow (No Mocks)

## Objective
Validate complete filter and search workflow end-to-end using real Django backend with real database queries, verifying OR/AND logic and all filter combinations without mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_filter_search_complete.yaml`
- [ ] Test steps:
  1. Start real Django backend with E2E test data (100+ flyers)
  2. Launch iOS app and navigate to feed
  3. Apply single category filter (e.g., Events)
  4. Assert: feed shows only Events flyers (verify via backend database query)
  5. Apply multiple category filters (Events OR Nightlife)
  6. Assert: feed shows Events OR Nightlife (verify OR logic via database)
  7. Toggle "Near Me" filter (within 5km)
  8. Assert: feed shows only flyers within 5km (verify distances via geopy)
  9. Combine category + Near Me filters
  10. Assert: feed shows (Events OR Nightlife) AND (within 5km) - verify AND logic
  11. Enter search term (e.g., "concert")
  12. Assert: feed shows filtered results matching search in title/description
  13. Verify search ranking (relevance) matches backend query order
  14. Clear all filters
  15. Assert: feed returns to full unfiltered state
  16. Test all filter combinations (3 categories, Near Me on/off, search text)
- [ ] Real database query validation:
  - Query SQL logged and verified against filter UI state
  - Result counts match between backend query and app display
  - OR logic: multiple categories union results correctly
  - AND logic: category + location + search intersects correctly
- [ ] Performance under realistic conditions:
  - Filtered queries complete in <500ms (100+ flyers in database)
  - Database indexes utilized (verify via Django query EXPLAIN)
  - Search queries performant with full-text search
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Single category filter (each category: Events, Nightlife, Service)
- Multiple category filter (OR logic)
- Near Me filter (distance calculation with real geopy)
- Combined filters (category AND location)
- Search term filtering
- Combined search + category + location (complex AND/OR)
- Filter state persistence (apply filters, navigate away, return - filters maintained)
- Clear filters functionality
- Empty results (filter combination that returns 0 flyers)
- Performance with large result sets

## Files to Modify/Create
- `maestro/flows/m01-e05/filter_search_complete_workflow.yaml`
- `maestro/flows/m01-e05/filter_all_combinations.yaml`
- `maestro/flows/m01-e05/filter_empty_results.yaml`
- `pockitflyer_backend/scripts/verify_filter_query.py` (debug script to test filter SQL)
- `pockitflyer_backend/flyers/tests/test_e2e_filter_queries.py` (backend query validation)

## Dependencies
- m01-e05-t01 (E2E test data infrastructure)
- m01-e02-t01 through m01-e02-t06 (all filter/search implementation)
- m01-e02-t07 (basic E2E filter/search flow, which this extends)

## Notes
**Critical: NO MOCKS**
- Real Django REST API with actual database queries
- Real SQLite database with indexed query performance
- Real geopy distance calculations for Near Me filter
- Real iOS app making actual API requests with filter parameters

**Filter Logic Validation**:
- OR Logic (categories): `WHERE category IN ('Events', 'Nightlife')`
- AND Logic (category + location): `WHERE category IN (...) AND distance < 5km`
- Search: `WHERE (title ILIKE '%term%' OR description ILIKE '%term%')`
- Combined: `WHERE category IN (...) AND distance < 5km AND (title ILIKE '%term%' OR description ILIKE '%term%')`

**Database Query Verification**:
- Enable Django SQL logging during tests
- Capture actual SQL queries executed
- Assert queries use database indexes (verify EXPLAIN output)
- Verify query result count matches app display

**Filter Combinations to Test** (8 total):
1. No filters (baseline: all flyers)
2. Category only (Events)
3. Multiple categories (Events OR Nightlife)
4. Near Me only (within 5km)
5. Category + Near Me (Events AND within 5km)
6. Search only ("concert")
7. Category + Search (Events AND "concert")
8. Category + Near Me + Search (Events AND within 5km AND "concert")

**Performance Validation**:
- Measure API response time for each filter combination
- All queries must complete in <500ms
- Verify database indexes are used (check EXPLAIN plan)
- Test with 100+ flyers to simulate realistic load

**Edge Cases**:
- Empty results (filter combination returns 0 flyers) - should show empty state UI
- Search with special characters (quotes, apostrophes)
- Very long search terms (>100 characters)
- Rapid filter toggling (race conditions)

**State Persistence Test**:
1. Apply filters (Events + Near Me)
2. Navigate to flyer details
3. Navigate back to feed
4. Assert: filters still active (Events + Near Me maintained)
5. Verify API not re-queried unnecessarily (cache working)
