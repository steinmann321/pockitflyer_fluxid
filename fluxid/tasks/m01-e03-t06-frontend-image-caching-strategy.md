---
id: m01-e03-t06
epic: m01-e03
title: Implement Frontend Image Caching Strategy
status: pending
priority: medium
tdd_phase: red
---

# Task: Implement Frontend Image Caching Strategy

## Objective
Configure and optimize image caching on the frontend to minimize network requests, improve load times, and handle poor network conditions gracefully using cached_network_image or similar package.

## Acceptance Criteria
- [ ] Images cached on device after first load
- [ ] Cached images load instantly on subsequent views
- [ ] Cache respects reasonable size limits (e.g., 100MB max)
- [ ] Cache invalidation strategy (LRU or time-based)
- [ ] Poor network handling: show cached version if available
- [ ] Offline mode: cached images still visible
- [ ] Loading placeholders during first fetch
- [ ] Error placeholders for failed fetches
- [ ] Cache cleared on app data clear (standard iOS behavior)
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Image loaded from network on first request
- Same image loaded from cache on second request
- Cache hit scenario (instant load)
- Cache miss scenario (network fetch)
- Poor network: cached image displayed
- No network + cached image: image displayed
- No network + no cache: error placeholder shown
- Cache size limits enforced (eviction of old images)
- Different images don't collide in cache

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/cached_flyer_image.dart` (wrapper for cached images)
- `pockitflyer_app/lib/services/image_cache_service.dart` (cache configuration)
- `pockitflyer_app/test/widgets/cached_flyer_image_test.dart`
- `pockitflyer_app/test/services/image_cache_service_test.dart`
- `pockitflyer_app/pubspec.yaml` (ensure cached_network_image dependency)

## Dependencies
- Task m01-e03-t03 (image carousel widget)
- cached_network_image Flutter package (or flutter_cache_manager)

## Notes
- Use `cached_network_image` package (popular, well-maintained)
- Configuration: maxCacheAge (e.g., 7 days), maxCacheSize (e.g., 100MB)
- Eviction policy: LRU (least recently used) is standard
- Loading placeholder: can use shimmer effect or simple grey box
- Error placeholder: use asset image (e.g., broken image icon)
- Integration: ImageCarousel widget uses CachedNetworkImage instead of Image.network
- Cache location: iOS app documents directory (managed by package)
- Future enhancement: preload images in feed for faster detail view loads
