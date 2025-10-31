---
id: m02-e04-t09
epic: m02-e04
title: Performance Validation for M02 Features
status: pending
priority: high
tdd_phase: red
---

# Task: Performance Validation for M02 Features

## Objective
Validate that all M02 authentication and profile management features meet performance targets under realistic network conditions and data volumes. Tests measure response times, database query performance, and user experience quality using real Django backend and real iOS app with no mocks.

## Acceptance Criteria
- [ ] Performance test script: `scripts/validate_m02_performance.py`
- [ ] Authentication performance benchmarks:
  - Registration API call: <2 seconds (includes password hashing, profile creation, token generation)
  - Login API call: <3 seconds (includes password verification, token generation)
  - Logout: <1 second (token invalidation, local state clear)
  - Token validation: <500ms (verify token signature, check expiration)
- [ ] Profile management performance benchmarks:
  - Profile retrieval (own profile): <2 seconds
  - Profile retrieval (other user): <2 seconds
  - Profile update (name, bio only): <2 seconds
  - Profile picture upload (1-2MB image): <5 seconds
  - Profile picture download (thumbnail): <500ms per image
- [ ] Privacy settings performance benchmarks:
  - Settings retrieval: <1 second
  - Settings update (toggle): <2 seconds
- [ ] Database query performance benchmarks:
  - User lookup by email: <50ms (indexed query)
  - Profile lookup by user_id: <50ms (foreign key indexed)
  - Privacy settings lookup by user_id: <50ms (foreign key indexed)
  - Feed API with creator profiles (100+ flyers): <500ms (includes joins)
- [ ] UI responsiveness benchmarks:
  - Login screen load: <1 second
  - Profile screen load: <2 seconds
  - Edit profile screen load: <1 second
  - Privacy settings screen load: <1 second
  - Header avatar update after login: <500ms
- [ ] Network condition testing:
  - Test under 3G network (simulated): All operations complete within 2x benchmark time
  - Test under 4G network (simulated): All operations meet benchmark times
  - Test under WiFi: All operations meet benchmark times
- [ ] Scalability testing:
  - 100+ users in database: No performance degradation
  - 1000+ flyers in database (M01 data): Feed API still <500ms
  - 50+ profile pictures loaded in feed: Pagination smooth, no UI lag
- [ ] Performance report generated:
  - All benchmarks: PASS/FAIL status with actual measurements
  - Performance trends: Compare against baseline (M01 performance)
  - Bottleneck identification: Slowest queries, API calls, UI renders
  - Recommendations: Optimization opportunities
- [ ] All performance tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Registration API response time
- Login API response time
- Profile retrieval response time (own and other users)
- Profile update response time (with and without image upload)
- Privacy settings retrieval and update response times
- Database query execution times (all critical queries)
- UI screen load times (all M02 screens)
- Image upload and download times
- Feed API response time with creator profiles (M01/M02 integration)
- Network condition variations (3G, 4G, WiFi)
- Scalability under realistic data volumes (100+ users, 1000+ flyers)

## Files to Modify/Create
- `scripts/validate_m02_performance.py` (main performance validation script)
- `scripts/performance_helpers.py` (helper functions for benchmarking)
- `pockitflyer_backend/users/tests/test_performance.py` (backend performance tests)
- `pockitflyer_app/test/performance_test.dart` (Flutter performance tests)
- `docs/m02_performance_report_template.md` (report template)
- `docs/m02_performance_report_YYYY-MM-DD.md` (generated report)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure)
- m02-e04-t02 through t08 (all E2E functional tests must pass first)
- All M02 epics complete (m02-e01, m02-e02, m02-e03)

## Notes
**Critical: PRODUCTION-LIKE CONDITIONS**
- Real Django server running on localhost
- Real SQLite database with realistic data volumes (100+ users, 1000+ flyers)
- Real iOS app on simulator (performance baseline)
- Real network conditions simulated (3G, 4G, WiFi throttling)

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**Performance Benchmarks**:

| Feature | Target | Measurement Method |
|---------|--------|-------------------|
| Registration API | <2s | Time from API call to response |
| Login API | <3s | Time from API call to response |
| Profile retrieval | <2s | Time from API call to response |
| Profile update (no image) | <2s | Time from API call to response |
| Profile picture upload | <5s | Time from upload start to completion |
| Privacy settings update | <2s | Time from toggle to backend confirmation |
| Feed API (100+ flyers) | <500ms | Time from API call to response |
| Database user lookup | <50ms | SQL query execution time (EXPLAIN ANALYZE) |
| Login screen load | <1s | Time from navigation to fully rendered |
| Profile screen load | <2s | Time from navigation to data displayed |

**Performance Test Script Structure**:
```python
# scripts/validate_m02_performance.py
def validate_m02_performance():
    results = []

    # Start backend and seed data
    start_backend()
    seed_large_dataset()  # 100+ users, 1000+ flyers

    # Test registration performance
    results.append(test_registration_performance())

    # Test login performance
    results.append(test_login_performance())

    # Test profile retrieval performance
    results.append(test_profile_retrieval_performance())

    # Test profile update performance
    results.append(test_profile_update_performance())

    # Test database query performance
    results.append(test_database_query_performance())

    # Test UI performance (Maestro with timing assertions)
    results.append(test_ui_performance())

    # Test network conditions (3G, 4G, WiFi)
    results.append(test_network_conditions())

    # Generate report
    generate_performance_report(results)

    return all(r['status'] == 'PASS' for r in results)
```

**Backend Performance Testing**:
Use Django Debug Toolbar and SQL logging to measure:
1. Number of database queries per API call
2. Query execution time (EXPLAIN ANALYZE)
3. N+1 query detection (prefetch_related, select_related)
4. Database connection pooling

**Frontend Performance Testing**:
Use Flutter DevTools and Maestro timing assertions:
1. Screen render time (time to first paint)
2. Image loading time (network + decode + render)
3. State management overhead (setState calls)
4. ListView/ScrollView smoothness (frame rate)

**Network Condition Simulation**:
Use iOS Simulator Network Link Conditioner:
1. **3G** (slow): 1.6 Mbps down, 768 Kbps up, 100ms latency
2. **4G** (medium): 10 Mbps down, 5 Mbps up, 50ms latency
3. **WiFi** (fast): 50 Mbps down, 20 Mbps up, 10ms latency

**Database Query Optimization Checks**:
1. Indexes on all queried fields:
   - `User.email` (unique index)
   - `Profile.user_id` (foreign key index)
   - `PrivacySettings.user_id` (foreign key index)
   - `Flyer.creator_id` (foreign key index)
2. No N+1 queries in feed API (use `select_related('creator__profile')`)
3. Pagination limits (max 20 flyers per page)
4. Query result caching (optional, for future optimization)

**Image Performance Optimization Checks**:
1. Profile pictures resized on upload (max 200x200px for storage)
2. Thumbnails generated for feed (50x50px)
3. Image caching on iOS (NSCache or third-party library)
4. Lazy loading in feed (images load as scrolled into view)
5. Placeholder images shown while loading (no blank spaces)

**Performance Report Format**:
```markdown
# M02 Performance Validation Report

**Date**: 2025-01-15
**Test Environment**: iOS Simulator (iPhone 14), Django on localhost
**Data Volume**: 100 users, 1000 flyers, 70% users with profile pictures
**Overall Status**: ✅ ALL BENCHMARKS PASSED

## Performance Benchmarks

### Authentication
- **Registration API**: 1.6s (target: <2s) ✅
- **Login API**: 2.4s (target: <3s) ✅
- **Logout**: 0.3s (target: <1s) ✅
- **Token validation**: 120ms (target: <500ms) ✅

### Profile Management
- **Profile retrieval (own)**: 1.8s (target: <2s) ✅
- **Profile retrieval (other)**: 1.7s (target: <2s) ✅
- **Profile update (no image)**: 1.5s (target: <2s) ✅
- **Profile picture upload (2MB)**: 4.2s (target: <5s) ✅
- **Profile picture download**: 320ms (target: <500ms) ✅

### Privacy Settings
- **Settings retrieval**: 0.8s (target: <1s) ✅
- **Settings update**: 1.3s (target: <2s) ✅

### Database Queries
- **User lookup by email**: 15ms (target: <50ms) ✅
- **Profile lookup by user_id**: 12ms (target: <50ms) ✅
- **Feed API (100 flyers)**: 420ms (target: <500ms) ✅

### UI Responsiveness
- **Login screen load**: 0.7s (target: <1s) ✅
- **Profile screen load**: 1.6s (target: <2s) ✅
- **Edit profile screen load**: 0.9s (target: <1s) ✅

### Network Conditions
- **3G**: All operations within 2x benchmark (acceptable) ✅
- **4G**: All operations meet benchmarks ✅
- **WiFi**: All operations meet benchmarks ✅

## Performance Comparison (M01 vs M02)

| Metric | M01 Baseline | M02 Result | Change |
|--------|--------------|------------|--------|
| Feed API | 380ms | 420ms | +40ms (+10%) ⚠️ |
| Screen load | 0.5s | 0.7s | +0.2s (+40%) ⚠️ |

**Analysis**: Slight performance regression due to additional profile data in feed API. Acceptable trade-off for improved UX (creator profiles visible).

## Bottlenecks Identified
1. **Feed API**: Additional JOIN for creator profiles adds 40ms
   - Recommendation: Add database index on `Profile.user_id` (already present)
   - Recommendation: Consider caching creator profile data (future optimization)

2. **Profile picture upload**: Network upload time dominates (3.5s of 4.2s)
   - Recommendation: Add image compression before upload (future optimization)
   - Recommendation: Show progress indicator during upload (UX improvement)

## Scalability Assessment
- ✅ 100+ users: No performance degradation
- ✅ 1000+ flyers: Feed API still meets benchmark (<500ms)
- ✅ 50+ profile pictures in feed: Smooth scrolling, no lag

## Recommendations
1. **Immediate**: All benchmarks passed, no blocking issues
2. **Short-term**: Implement image compression before upload (reduce upload time)
3. **Medium-term**: Add progress indicators for long operations (>2s)
4. **Long-term**: Investigate caching strategies for creator profile data

## Conclusion
**M02 PERFORMANCE VALIDATED FOR PRODUCTION**
All benchmarks passed. Performance acceptable under realistic conditions.
```

**Performance Monitoring Tools**:
1. **Backend**: Django Debug Toolbar, django-silk (SQL profiling)
2. **Frontend**: Flutter DevTools (performance overlay, timeline)
3. **Network**: Charles Proxy, iOS Network Link Conditioner
4. **Database**: SQLite EXPLAIN ANALYZE, query logging

**Acceptable Performance Degradation**:
- M02 may add slight overhead compared to M01 (additional profile data)
- Acceptable if within 20% of M01 baseline
- Unacceptable if any benchmark fails (red flag for optimization)

**Performance Regression Detection**:
- Compare M02 performance against M01 baseline
- Flag any operation >20% slower than M01
- Document reasons for regression (e.g., additional data, new features)
- Decide: Acceptable trade-off or needs optimization?

**Success Indicators**:
- All benchmarks passed ✅
- No operation exceeds 2x target time ✅
- UI feels responsive (no lag, no jank) ✅
- Performance acceptable under 3G network ✅
- Scalability validated (100+ users, 1000+ flyers) ✅
- Performance report generated with recommendations ✅
