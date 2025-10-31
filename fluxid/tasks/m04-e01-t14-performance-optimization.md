---
id: m04-e01-t14
epic: m04-e01
title: Performance Optimization and Polish
status: pending
priority: medium
tdd_phase: red
---

# Task: Performance Optimization and Polish

## Objective
Optimize flyer creation flow for performance, especially image uploads and geocoding, with polished user experience.

## Acceptance Criteria
- [ ] Image compression before upload (max 2048px, 85% quality)
- [ ] Upload progress indicator for files >1MB
- [ ] Geocoding timeout: 10 seconds with clear error message
- [ ] Debounced validation (don't validate on every keystroke)
- [ ] Loading skeletons during initial category fetch
- [ ] Smooth transitions between form steps
- [ ] Form field autofocus progression
- [ ] Success animation on publish
- [ ] Haptic feedback on interactions (iOS)
- [ ] Accessibility: screen reader labels, semantic ordering
- [ ] All tests marked with appropriate `tdd_*` markers after passing

## Test Coverage Requirements
- Image compression quality and size
- Upload progress callback accuracy
- Geocoding timeout enforcement
- Validation debouncing
- Loading state rendering
- Accessibility compliance
- Animation completion
- Performance benchmarks (upload time, screen render time)

## Files to Modify/Create
- `pockitflyer_app/lib/services/image_compression_service.dart`
- `pockitflyer_app/lib/screens/create_flyer_screen.dart` (polish)
- `pockitflyer_app/test/services/image_compression_service_test.dart`
- `pockitflyer_app/test/performance/create_flyer_performance_test.dart`

## Dependencies
- m04-e01-t10 (creation screen)
- m04-e01-t11 (API client)
- Flutter `image` package for compression

## Notes
- Use `flutter_image_compress` for client-side compression
- Upload progress: track bytes sent / total bytes
- Debounce validation: 500ms delay after typing stops
- Success animation: checkmark with fade-in
- Haptic feedback: light impact on button press
- Accessibility: test with VoiceOver
- Performance target: <3s upload for 5 images on 4G
- Consider progressive JPEG for faster preview
