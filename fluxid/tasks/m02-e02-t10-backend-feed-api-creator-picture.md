---
id: m02-e02-t10
epic: m02-e02
title: Update Feed API to Include Creator Profile Pictures
status: pending
priority: medium
tdd_phase: red
---

# Task: Update Feed API to Include Creator Profile Pictures

## Objective
Update Django feed API endpoint to include creator profile picture URLs in flyer data, enabling frontend to display creator avatars in flyer cards.

## Acceptance Criteria
- [ ] Feed API response includes `creator_profile_picture_url` for each flyer
- [ ] `creator_profile_picture_url` is absolute URL (not relative path)
- [ ] Default avatar URL returned when creator has no profile picture
- [ ] Thumbnail version of profile picture used (128x128px, not full size)
- [ ] No N+1 query problem (use select_related/prefetch_related)
- [ ] API performance: response time increase < 50ms
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Feed API returns creator_profile_picture_url for each flyer
- Default avatar URL returned when creator has no picture
- Profile picture URL is absolute and properly formatted
- Thumbnail URL returned (not original image URL)
- No N+1 queries: verify database query count with/without change
- Feed response time within acceptable range

## Files to Modify/Create
- `pockitflyer_backend/flyers/serializers.py` (update FlyerSerializer)
- `pockitflyer_backend/flyers/views.py` (optimize queries)
- `pockitflyer_backend/flyers/tests/test_feed_api.py` (update tests)

## Dependencies
- m01-e01-t04 (Existing feed API)
- m02-e02-t03 (Image storage service with thumbnails)
- m02-e01-t01 (Profile model)

## Notes
- Use select_related('creator__profile') to avoid N+1 queries
- Return thumbnail URL to reduce bandwidth (128x128px, not 512x512px)
- Default avatar should be consistent across all APIs
- Consider adding creator_name to response for consistency
- Backwards compatible: frontend should handle missing field gracefully
