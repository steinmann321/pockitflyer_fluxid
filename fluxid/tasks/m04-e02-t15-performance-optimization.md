---
id: m04-e02-t15
epic: m04-e02
title: Optimize Edit Workflow Performance
status: pending
priority: low
tdd_phase: red
---

# Task: Optimize Edit Workflow Performance

## Objective
Optimize performance of flyer editing workflow focusing on image operations, geocoding efficiency, and UI responsiveness.

## Acceptance Criteria
- [ ] Image thumbnails generated and cached for fast display
- [ ] Large images compressed before upload
- [ ] Geocoding skipped when address unchanged (performance test confirms)
- [ ] Database queries optimized with select_related/prefetch_related
- [ ] Frontend image loading uses caching strategy
- [ ] Edit screen loads in <500ms with cached data
- [ ] Save operation completes in <2s for text-only changes
- [ ] Save operation provides progress feedback for image uploads
- [ ] All tests marked with appropriate TDD tags after passing

## Test Coverage Requirements
- Image thumbnail generation performance
- Image upload compression reduces size
- Geocoding only called when address changed (mock verification)
- Database query count optimized (use Django Debug Toolbar)
- Edit screen load time measured
- Save operation performance for various change types
- Progress feedback displayed during long operations

## Files to Modify/Create
- `pockitflyer_backend/flyers/services/image_processing.py` (thumbnail generation)
- `pockitflyer_backend/flyers/views.py` (query optimization)
- `pockitflyer_app/lib/services/image_cache_service.dart` (frontend caching)
- `pockitflyer_app/lib/widgets/upload_progress_indicator.dart` (progress feedback)
- Performance test files for both backend and frontend

## Dependencies
- M04-E02-T02 (Backend update API)
- M04-E02-T05 (Frontend edit screen)
- M04-E02-T09 (Image edit widget)

## Notes
- Use Pillow for thumbnail generation (max 300px for list view)
- Consider using django-imagekit for automatic thumbnail generation
- Image compression: target 85% quality, max 2048px dimensions
- Frontend caching: use cached_network_image package
- Progress indicators improve perceived performance
- Geocoding check: compare address string before API call
- This is optimization work - can be deferred if time-constrained
- Profile actual usage to identify real bottlenecks before optimizing
