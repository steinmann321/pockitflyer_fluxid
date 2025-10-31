---
id: m01-e04-t07
epic: m01-e04
title: Profile and Creator Flyers Performance Optimization
status: pending
priority: medium
tdd_phase: red
---

# Task: Profile and Creator Flyers Performance Optimization

## Objective
Optimize backend database queries and frontend caching to ensure profile pages load in < 2s and perform efficiently.

## Acceptance Criteria
- [ ] Database index on flyers.creator_id verified and optimized
- [ ] Profile API response time < 200ms for 95th percentile
- [ ] Creator flyers API response time < 500ms for 95th percentile (20 flyers)
- [ ] Frontend image caching strategy implemented for profile pictures
- [ ] Frontend creator flyers data cached during session
- [ ] Profile picture optimization: images resized/compressed on backend
- [ ] Query optimization: creator flyers fetches minimal data with select_related/prefetch_related
- [ ] Performance tests validate load time targets
- [ ] All tests marked with `@pytest.mark.tdd_green` / `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- API response time benchmarks (profile, creator flyers)
- Database query count and efficiency (N+1 prevention)
- Image optimization validation (file size, dimensions)
- Frontend cache hit rates
- Load testing with realistic data volumes (users with 100+ flyers)
- Performance regression tests

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (optimize queries)
- `pockitflyer_backend/flyers/views.py` (optimize creator filter queries)
- `pockitflyer_backend/users/tests/test_performance.py`
- `pockitflyer_backend/flyers/tests/test_performance.py`
- `pockitflyer_app/lib/services/image_cache_service.dart`
- `pockitflyer_app/test/services/image_cache_service_test.dart`

## Dependencies
- m01-e04-t01 (User profile API)
- m01-e04-t02 (Creator flyers API)
- m01-e04-t04 (Creator flyers feed UI)

## Notes
- Profile picture optimization: max 500px width, JPEG compression 85%
- Use Django select_related for creator FK in flyer queries
- Use prefetch_related for flyer images
- Frontend: use cached_network_image package with custom cache strategy
- Consider Redis caching for frequently accessed profiles (future enhancement)
- Performance targets based on 4G mobile network assumptions
- Test with production-like data volumes for realistic benchmarks
- Document optimization decisions and trade-offs
