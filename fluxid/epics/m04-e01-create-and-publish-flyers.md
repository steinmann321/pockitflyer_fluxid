---
id: m04-e01
title: Create and Publish Flyers
milestone: m04
status: pending
---

# Epic: Create and Publish Flyers

## Overview
Authenticated users access flyer creation via the "Flyern" button in the header. They upload 1-5 images with validation and preview, add title/caption and two free-text fields with character limits, select category tags (Events, Nightlife, Service, etc.), input a location address for backend geocoding, and set publication/expiration dates. Upon publishing, the flyer appears immediately in the main feed with complete backend persistence including image storage and geocoding integration.

## Scope
- "Flyern" button navigation to creation screen (requires authentication)
- Image upload UI (1-5 images required, validation, preview, reordering)
- Text input fields (title/caption, two free-text information fields with character limits)
- Category tag selection UI (multi-select from predefined options)
- Address input UI for location (backend geocodes to coordinates)
- Date pickers for publication start and expiration dates (validation: expiration > publication)
- Publish action with optimistic UI update
- Backend flyer creation API endpoint
- Database models for flyers with all fields (images, text, tags, geocoordinates, dates)
- Image storage integration using Pillow for processing
- Geocoding service integration (geopy) for address-to-coordinate conversion
- Backend validation (required fields, date logic, image limits, address validation)
- Circuit breakers and retry mechanisms for geocoding service

## Success Criteria
- [ ] "Flyern" button in header navigates to creation screen only when authenticated [Test: authenticated user, unauthenticated user redirect to login]
- [ ] Users can upload 1-5 images with live preview and reordering [Test: 0 images rejection, 1-5 images success, 6+ images rejection, various formats/sizes]
- [ ] Image upload shows progress feedback for large files [Test: large image uploads, slow network conditions]
- [ ] Text fields enforce character limits with visible counter [Test: exact limit, over limit prevention, empty validation]
- [ ] Category tag selection allows multiple tags from predefined list [Test: single tag, multiple tags, no tags validation, all available categories]
- [ ] Address input sends to backend for geocoding [Test: valid addresses, invalid addresses, international addresses, geocoding failures]
- [ ] Backend converts address to geocoordinates using geopy [Test: various address formats, geocoding service timeout, service down, rate limiting]
- [ ] Date pickers validate expiration is after publication date [Test: valid date range, invalid date range, same-day dates, past dates]
- [ ] Published flyer appears in main feed immediately [Test: optimistic update, feed refresh, network failures, rollback on error]
- [ ] Backend persists all flyer data correctly [Test: database insertion, image storage, coordinate storage, date storage]
- [ ] Circuit breakers prevent geocoding service failures from blocking creation [Test: geocoding timeout, service down, partial failures, retry logic]
- [ ] All required fields are validated before submission [Test: missing images, missing text, missing location, missing dates, missing tags]
- [ ] Image processing handles various formats and sizes [Test: JPEG/PNG/HEIC, small/large files, orientation, compression]
- [ ] Creation flow is polished and intuitive [Test: user workflow completeness, error messages, loading states, success confirmation]

## Dependencies
- M02 (User Authentication) for authenticated user context
- M01 (Anonymous Discovery) for feed display of new flyers
- External: geopy library for geocoding
- External: Pillow library for image processing

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Backend handles 100% of geocoding - frontend never performs address conversion
- Image upload must show progress feedback for files >1MB
- Geocoding errors must provide clear user guidance (e.g., "Address not found, please try a different format")
- Optimistic UI update must rollback gracefully on API failure
- Consider edge cases: concurrent uploads, network interruptions, geocoding API failures
- All external service calls use circuit breakers with exponential backoff
- Image storage requires proper cleanup on creation failure
- Publication date defaults to "now", expiration date defaults to "now + 30 days"
