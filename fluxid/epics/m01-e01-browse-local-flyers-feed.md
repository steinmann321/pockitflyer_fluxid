---
id: m01-e01
title: User Browses Local Flyers Feed
milestone: m01
status: pending
---

# Epic: User Browses Local Flyers Feed

## Overview
Users open the app and browse a smart-ranked feed of local digital flyers without authentication. The feed displays complete flyer cards with creator identity, images, location with distance, title, description, and validity period. Users can scroll through the feed and pull-to-refresh to update content. This epic delivers the core browsing experience with complete backend integration including Django REST API, database models, and geocoding service.

## Scope
- Home screen with flyer feed (smart-ranked by recency, proximity, relevance)
- Complete flyer card display (creator info, image carousel, location+distance, title, description, validity)
- Pull-to-refresh gesture to update feed
- Device location access and permission handling
- Django REST API endpoints for flyer retrieval
- Database models for flyers and users with proper indexing
- Geocoding integration (geopy) for address-to-coordinate conversion
- Distance calculation based on user's device location
- Backend circuit breakers and retry mechanisms for external services

## Success Criteria
- [ ] Users see smart-ranked feed on app launch without authentication [Test: fresh install, various location scenarios, empty state]
- [ ] Each flyer card displays all required information accurately [Test: various content types, long/short text, 1-5 images, missing optional fields]
- [ ] Distance calculations are accurate within 100m [Test: various user-flyer distance combinations, geocoding accuracy, coordinate edge cases]
- [ ] Pull-to-refresh updates feed with new/changed flyers [Test: new flyers added, content changes, deletions, no changes scenario]
- [ ] Feed loads within 2 seconds on standard network [Test: 3G/4G/5G/WiFi conditions, various data volumes]
- [ ] Device location permission is requested and handled gracefully [Test: granted, denied, not determined, location services disabled]
- [ ] Backend API returns flyers with complete data [Test: database queries with indexes, pagination, sorting, filtering by location]
- [ ] Geocoding service converts addresses to coordinates reliably [Test: various address formats, international addresses, invalid addresses, service failures]
- [ ] Circuit breakers prevent cascading failures from geocoding service [Test: service timeout, service down, rate limiting, partial failures]
- [ ] Database queries perform efficiently with proper indexing [Test: 1000+ flyers, complex queries, concurrent access]

## Dependencies
- No dependencies on other epics (foundational flow)
- External: geopy library for geocoding
- External: iOS CoreLocation framework for device location

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- This is the foundational epic - all other user flows build on this
- Backend handles 100% of geocoding - frontend only works with coordinates
- Smart ranking algorithm balances recency (newest first), proximity (closest first), relevance (user preferences - deferred to later milestone)
- Pull-to-refresh is the only manual feed update mechanism (no auto-refresh)
- Database schema must support all required flyer and user fields
- All external service calls must use circuit breakers with exponential backoff
- Location permission flow must follow iOS best practices
