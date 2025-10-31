---
id: m01-e05-t07
epic: m01-e05
title: E2E Test - Performance Validation Under Realistic Conditions (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Performance Validation Under Realistic Conditions (No Mocks)

## Objective
Validate that M01 anonymous discovery platform meets all performance targets under realistic production-like conditions including network latency, large datasets, and concurrent operations without mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_performance_validation.yaml`
- [ ] Performance test scenarios:
  1. **Feed Load Performance**:
     - Start backend with 100+ flyers in database
     - Launch iOS app (fresh install)
     - Measure time from launch to feed display
     - Assert: <2 seconds (target from milestone)
  2. **Filtered Query Performance**:
     - Apply complex filter: (Events OR Nightlife) AND (within 5km) AND search("concert")
     - Measure API response time
     - Assert: <500ms (target from milestone)
  3. **Pagination Performance**:
     - Scroll through feed to trigger 5 pagination requests
     - Measure each pagination API call
     - Assert: each <500ms, smooth scrolling (60fps)
  4. **Image Loading Performance**:
     - Navigate to flyer with 5 images
     - Measure time to load all images
     - Assert: thumbnail <500ms, high-res <2 seconds per image
  5. **Network Latency Simulation**:
     - Add 50-200ms artificial network delay (iOS Network Link Conditioner)
     - Repeat feed load, filter query, pagination tests
     - Assert: all targets still met (graceful degradation)
  6. **Database Query Performance**:
     - Enable Django SQL logging
     - Capture all queries during feed load
     - Assert: queries use indexes (EXPLAIN plan shows index usage)
     - Assert: N+1 query problem avoided (no queries inside loops)
  7. **Memory Performance**:
     - Navigate through 20 screens deep (feed → profiles → details → back → back...)
     - Measure iOS app memory usage
     - Assert: <100MB memory footprint
     - Assert: no memory leaks (memory returns to baseline after navigation)
  8. **Concurrent Operations**:
     - Trigger pull-to-refresh while scrolling
     - Apply filter while images loading
     - Navigate while search query in-flight
     - Assert: no crashes, no race conditions, no visual glitches
- [ ] Performance metrics logging:
  - All timings logged to test output
  - Backend SQL queries logged with execution times
  - iOS memory and CPU usage logged
  - Network request/response times logged
- [ ] Performance regression detection:
  - Baseline metrics established (first successful run)
  - Subsequent runs compared to baseline
  - Alert if any metric degrades >10%
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Feed load: cold start, warm start (cached data)
- Query performance: simple filters, complex filters, search
- Pagination: first page, subsequent pages, infinite scroll
- Image loading: single image, carousel, thumbnail vs high-res
- Network conditions: ideal (0ms), good (50ms), fair (200ms), poor (500ms)
- Database queries: index usage, N+1 prevention, query optimization
- Memory: navigation depth, image caching, state management
- Concurrency: simultaneous operations, race conditions
- 90th percentile performance (not just average)

## Files to Modify/Create
- `maestro/flows/m01-e05/performance_validation.yaml`
- `maestro/flows/m01-e05/performance_network_latency.yaml`
- `maestro/flows/m01-e05/performance_memory_stress.yaml`
- `maestro/flows/m01-e05/performance_concurrent_operations.yaml`
- `pockitflyer_backend/scripts/analyze_query_performance.py` (SQL EXPLAIN analysis)
- `scripts/network_conditioner_setup.sh` (automate Network Link Conditioner)
- `scripts/measure_performance.py` (extract and analyze Maestro timing logs)

## Dependencies
- m01-e05-t01 (E2E test data infrastructure - 100+ flyers)
- m01-e05-t02 through t06 (all workflow E2E tests)

## Notes
**Critical: NO MOCKS**
- Real Django backend with real database queries
- Real SQLite database with 100+ flyers (realistic data volume)
- Real geopy geocoding (pre-computed in test data, but service available)
- Real iOS app making actual HTTP requests
- Real network latency simulation (iOS Network Link Conditioner)

**Performance Targets** (from M01 milestone):
- Feed load: <2 seconds (cold start)
- Filtered queries: <500ms
- Image load: <2 seconds per high-res image
- Pagination: smooth 60fps scrolling
- Memory: <100MB footprint

**Network Latency Simulation**:
- Use iOS Network Link Conditioner or proxy (Charles, Proxyman)
- Simulate latencies: 0ms (ideal), 50ms (good), 200ms (fair), 500ms (poor)
- Test all workflows under each latency condition
- Document graceful degradation (e.g., loading indicators, cached data)

**Database Query Optimization Validation**:
1. Enable Django SQL logging: `settings.LOGGING` with DEBUG=True
2. Capture all SQL queries during feed load
3. Run EXPLAIN on each query
4. Assert indexes used: `EXPLAIN` output shows "USING INDEX"
5. Assert no N+1 queries: feed load should be ~5 queries (not 1 + N for N flyers)
   - Query 1: Fetch flyers with pagination
   - Query 2: Prefetch creators (JOIN or separate query with IN clause)
   - Query 3: Prefetch images (JOIN or separate query with IN clause)
   - Queries 4-5: Misc (user session, etc.)
6. Log query execution times: all queries <50ms individual, <200ms cumulative

**Memory Performance Testing**:
1. Start app, note baseline memory (e.g., 30MB)
2. Navigate through 20 screens deep
3. Measure peak memory (should be <100MB)
4. Navigate back to start
5. Measure final memory (should return to ~baseline, e.g., <40MB)
6. No memory leaks: memory doesn't grow unbounded with navigation

**Concurrent Operations Stress Test**:
- Scenario 1: Pull-to-refresh while scrolling
  - Start scrolling feed
  - Trigger pull-to-refresh mid-scroll
  - Assert: no visual glitches, no crashes, refresh completes correctly
- Scenario 2: Apply filter while images loading
  - Navigate to flyer with 5 images
  - While images loading, navigate back and apply filter
  - Assert: no crash, filter applies correctly, no memory leak from cancelled image loads
- Scenario 3: Navigate during search query
  - Enter search term (triggers API request)
  - Immediately navigate to profile (before search completes)
  - Assert: no crash, profile loads correctly, search request cancelled gracefully

**Performance Metrics Logging**:
- Maestro logs include step timings
- Extract timings with script: `scripts/measure_performance.py`
- Output format: JSON with metrics per test scenario
- Example:
  ```json
  {
    "feed_load_cold_start": "1.8s",
    "filter_query_complex": "420ms",
    "pagination_avg": "380ms",
    "image_load_high_res_avg": "1.6s",
    "memory_peak": "85MB"
  }
  ```

**Performance Regression Detection**:
1. First successful test run establishes baseline
2. Save baseline to `maestro/performance_baseline.json`
3. Subsequent runs compare to baseline
4. Alert if any metric >10% worse than baseline
5. Update baseline only when intentional (approved performance changes)

**Network Link Conditioner Setup** (iOS Simulator):
- macOS: Additional Tools for Xcode → Network Link Conditioner
- Profiles: WiFi, 4G LTE, 3G, Edge, custom (50ms, 200ms, 500ms latency)
- Automate via script: `scripts/network_conditioner_setup.sh`
- Run tests under each profile, document results

**90th Percentile Performance**:
- Don't just measure single run (may be lucky)
- Run each test 10 times
- Calculate 90th percentile (9th fastest out of 10)
- Use 90th percentile for target validation
- This accounts for variability (GC pauses, background tasks, etc.)
