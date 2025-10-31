---
id: m01-e07
title: E2E Milestone Validation (No Mocks)
milestone: m01
status: pending
tasks:
  - m01-e07-t01
  - m01-e07-t02
  - m01-e07-t03
  - m01-e07-t04
  - m01-e07-t05
---

# Epic: E2E Milestone Validation (No Mocks)

## Overview
Validates the complete Milestone 01 deliverable through end-to-end testing WITHOUT MOCKS. All tests run against real Django backend, real SQLite database, and real geopy geocoding service to verify the milestone works exactly as it will be shipped to users.

## Scope
- Real Django REST API server running locally
- Real SQLite database with test flyer data
- Real geopy geocoding service integration
- Complete user workflows from anonymous browsing to navigation
- Performance validation under realistic iOS device conditions
- Error scenarios with actual service failures
- Cross-stack integration validation (Flutter app → Django API → Database → External services)

## Success Criteria
- [ ] Anonymous user can launch app and browse flyer feed end-to-end [Test: fresh install on real iOS device, API returns real data, images load, scroll works]
- [ ] Category and proximity filtering work with real backend [Test: apply filters, API processes queries correctly, feed updates with real filtered results]
- [ ] Search filters feed in real-time with backend integration [Test: type search query, API processes search, results update, special characters handled]
- [ ] Image carousels load real images and swipe correctly [Test: multi-image flyers, real image URLs from backend, swipe gestures smooth on device]
- [ ] Location services work with real iOS permissions and GPS [Test: request permission, device provides real coordinates, distance calculations accurate]
- [ ] Map navigation opens Apple Maps with correct destination [Test: tap location button, Maps app launches, destination coordinates match flyer location]
- [ ] Creator profile navigation works end-to-end [Test: tap creator, profile loads from API, shows creator's real flyers, back navigation works]
- [ ] Pull-to-refresh updates feed with real backend data [Test: trigger refresh, API called, new flyers appear if available, loading indicators work]
- [ ] System handles real network conditions gracefully [Test: slow 3G, intermittent connectivity, timeout scenarios, retry logic works]
- [ ] Geocoding service failures are handled correctly [Test: geopy timeout, rate limiting, invalid addresses, circuit breaker engages]
- [ ] Performance meets targets on real iOS devices [Test: smooth 60fps scrolling, image loading, filter/search response times, memory usage acceptable]
- [ ] All milestone success criteria validated end-to-end [Test: reference m01 milestone criteria, verify each with real system]

## Tasks
- E2E test environment setup (real backend, database, geopy) (m01-e07-t01)
- Anonymous browsing user journey E2E validation (m01-e07-t02)
- Filter and search workflows E2E validation (m01-e07-t03)
- Location and navigation features E2E validation (m01-e07-t04)
- Error handling and performance E2E validation (m01-e07-t05)

## Dependencies
- m01-e01 (Backend API) - must be complete and deployed
- m01-e02 (Core Feed Display) - must be complete
- m01-e03 (Category/Proximity Filtering) - must be complete
- m01-e04 (Search and Updates) - must be complete
- m01-e05 (Location Services) - must be complete
- m01-e06 (Creator Profiles) - must be complete
- Real iOS device or simulator for testing
- geopy service access (or test/sandbox account)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks completed with real services (NO MOCKS)
- [ ] All milestone success criteria validated end-to-end
- [ ] Performance meets targets in realistic conditions
- [ ] Error handling verified with actual failures
- [ ] Complete vertical slice works as shipped to users

## Notes
**CRITICAL: This epic uses NO MOCKS**

All services, databases, and external integrations must be real and functional. This is the final validation that the milestone delivers on its promise to users.

**Setup Requirements:**
- Django development server running locally (manage.py runserver)
- SQLite database with realistic test flyer data (various categories, locations, images)
- geopy service access for real geocoding (requires internet connection)
- iOS device or simulator with location services enabled
- Real network conditions (can simulate slow/intermittent with tools)

**Test Data Requirements:**
- At least 20-30 test flyers with diverse characteristics:
  - All three categories (Events, Nightlife, Service)
  - Various locations (different distances from test user location)
  - 1-5 images per flyer
  - Different creators (to test profile views)
  - Current validity dates (not expired)
- Test creator profiles with multiple flyers
- Edge cases: very long titles/descriptions, special characters, international addresses

**What This Is NOT:**
- Not unit tests (those are in regular epic tasks)
- Not integration tests with mocks (those are in regular epic tasks)
- Not performance benchmarks in isolation
- Not load testing with thousands of users

**What This IS:**
- Validation that milestone works end-to-end as shipped
- Real user workflows through the complete stack
- Verification with actual services and data
- Final quality gate before milestone completion
- Proof that consumer-grade quality is achieved

**Key User Journeys to Validate:**
1. **Anonymous Discovery**: Launch app → Browse feed → Scroll → View images → Check distances
2. **Filtered Discovery**: Apply category filter → Apply proximity filter → View filtered results → Clear filters
3. **Search Discovery**: Enter search query → View real-time results → Clear search
4. **Creator Exploration**: Tap creator on flyer → View profile → Browse creator's flyers → Return to feed
5. **Location Navigation**: Request location permission → View distances → Tap location button → Open in Maps
6. **Content Updates**: Pull-to-refresh → See updated feed → Verify new content appears

**Performance Targets:**
- Feed scrolling: 60fps on iPhone 11 or newer
- Filter/search response: <500ms from interaction to UI update
- Image loading: Progressive loading, no blank screens
- Initial feed load: <2s on good network connection
- Pull-to-refresh: <3s for full update

**Error Scenarios to Validate:**
- No network connection: graceful error messages, retry options
- Slow network: loading indicators, no UI freeze
- geopy timeout: fallback handling, circuit breaker works
- Location permission denied: distances hidden, proximity filter disabled
- Empty search/filter results: helpful empty state messaging
- Backend API errors: appropriate error messages, recovery options
