---
id: m01-e03
title: User Views Flyer Details and Location
milestone: m01
status: pending
---

# Epic: User Views Flyer Details and Location

## Overview
Users interact with flyer cards to view detailed information and navigate to flyer locations. Users can swipe through image carousels (1-5 images), view complete flyer information, and tap the location to open it in their device's native map app with navigation capabilities. This epic delivers rich flyer interaction with seamless device integration.

## Scope
- Image carousel component with swipe gesture (1-5 images)
- Full flyer information display (expanded view if needed)
- Location tap handler to open native maps
- Deep linking to device map apps (Apple Maps on iOS)
- Image loading with caching and error handling
- Carousel pagination indicators
- Location coordinate passing to map apps

## Success Criteria
- [ ] Users can swipe through image carousel smoothly [Test: 1 image, 5 images, rapid swipes, slow swipes, edge cases at boundaries]
- [ ] Images load efficiently with caching [Test: first load, cached load, poor network, failed loads, image error states]
- [ ] Carousel shows current position indicator [Test: visual indicator updates with swipes, all positions 1-5]
- [ ] All flyer information is readable and properly formatted [Test: long text wrapping, short text, missing optional fields, date formatting]
- [ ] Tapping location opens device native map app [Test: iOS Maps opens with correct coordinates, navigation ready]
- [ ] Map app receives accurate coordinates [Test: verify pin placement matches flyer location, edge cases near poles/dateline]
- [ ] Deep linking handles errors gracefully [Test: no map app installed (unlikely on iOS), permission issues, invalid coordinates]
- [ ] Distance display is accurate and user-friendly [Test: <1km shows meters, >1km shows km, very far distances, same location]
- [ ] Validity period is clearly displayed [Test: future dates, expires today, expired flyers filtered out]
- [ ] Images maintain aspect ratio and quality [Test: portrait/landscape/square images, various resolutions, zoom if applicable]

## Dependencies
- Epic m01-e01 (requires flyer cards to exist)
- iOS Maps app (standard on iOS devices)
- Backend image storage and serving capability

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Image carousel supports 1-5 images per flyer
- Images are served from backend with proper URLs
- Frontend implements image caching to reduce network calls
- Map deep linking uses iOS Maps URL scheme: `maps://?q=lat,lng`
- Distance formatting: <1000m shows "XXX m", >=1000m shows "X.X km"
- Validity period shows end date only: "Valid until [date]"
- Expired flyers are filtered by backend (not shown in feed)
- Image error handling shows placeholder image
- Large images should be lazy loaded as user scrolls
