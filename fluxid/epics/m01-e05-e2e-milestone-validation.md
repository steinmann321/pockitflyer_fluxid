---
id: m01-e05
title: E2E Milestone Validation (No Mocks)
milestone: m01
status: pending
---

# Epic: E2E Milestone Validation (No Mocks)

## Overview
Validates the complete milestone m01 deliverable through end-to-end testing WITHOUT MOCKS. All tests run against real Django backend, real SQLite database, real geopy geocoding service, and real iOS app to verify the anonymous discovery experience works exactly as it will be shipped to users. This epic validates all four user flows together as a complete, production-ready discovery platform.

## Scope
- Real Django REST API server running (all endpoints operational)
- Real SQLite database with test flyer and user data
- Real geopy geocoding service integration
- Real iOS app with device location services
- Complete user workflows: browse, filter, search, view details, view profiles
- Performance validation under realistic conditions
- Error scenarios with actual service failures (geocoding timeout, network issues)
- Cross-workflow integration (filters + search + pull-to-refresh + navigation)

## Success Criteria
- [ ] Complete browse workflow: Launch app → see feed → scroll → pull-to-refresh → see updated content [Test: real backend + database + geocoding, verify all flyer fields, distance calculations accurate]
- [ ] Complete filter/search workflow: Apply category filters → toggle Near Me → enter search → see refined results [Test: all filter combinations with real database queries, verify OR/AND logic]
- [ ] Complete details workflow: Tap flyer → swipe image carousel → tap location → opens iOS Maps [Test: real images from backend, accurate coordinates, deep link works]
- [ ] Complete profile workflow: Tap creator → see profile → view creator's flyers → navigate back [Test: real user data, creator flyer filtering, scroll position preservation]
- [ ] Cross-workflow integration: Filter flyers → search → tap creator → view profile flyers → back → filters maintained [Test: state preservation across navigation]
- [ ] System performs within defined targets under realistic conditions [Test: 100+ flyers in database, network latency 50-200ms, queries <500ms]
- [ ] Geocoding service integration works end-to-end [Test: real addresses converted to coordinates, distance calculations accurate, circuit breaker prevents failures]
- [ ] Error handling works with actual service failures [Test: geocoding timeout, network disconnection, location permission denied, empty database]
- [ ] Data persists correctly across the full stack [Test: verify database state after operations, pull-to-refresh reflects database changes]
- [ ] All milestone success criteria validated end-to-end [Test: reference all 13 success criteria from m01 milestone document]

## Dependencies
- Epic m01-e01 (browse feed) must be complete
- Epic m01-e02 (filter and search) must be complete
- Epic m01-e03 (flyer details and location) must be complete
- Epic m01-e04 (creator profiles) must be complete
- Real backend deployment capability (local development environment)
- Test data seeding scripts for database
- geopy service access (production or test environment)
- iOS simulator or device for testing

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks completed with real services (NO MOCKS)
- [ ] All milestone success criteria validated end-to-end
- [ ] Performance meets targets in realistic conditions (<2s feed load, <500ms filtered queries)
- [ ] Error handling verified with actual failures (geocoding, network, location permissions)
- [ ] Complete vertical slice works as shipped to users (anonymous discovery is production-ready)

## Notes
**CRITICAL: This epic uses NO MOCKS**

All services, databases, and external integrations must be real and functional. This is the final validation that the milestone delivers on its promise to users.

**Setup Requirements:**
- Django backend running locally (`python manage.py runserver`)
- SQLite database with realistic test data (100+ flyers, 20+ users, various locations)
- geopy library installed and functional
- iOS simulator or device with location services enabled
- Test data seeding: diverse addresses (urban/rural), all categories, various validity periods
- Network condition simulation capability for testing degraded performance

**Test Data Characteristics:**
- 100+ flyers with diverse: categories (Events/Nightlife/Service), locations (various distances), images (1-5 per flyer), validity periods
- 20+ users with: profile pictures, various flyer counts (0-50 flyers per creator)
- Address formats: street addresses, landmarks, international formats
- Distance range: 0.1km to 50km from test user location

**What This Is NOT:**
- Not unit tests (those are in epic-specific tasks)
- Not integration tests with mocks (those are in epic-specific tasks)
- Not performance benchmarks (though performance is validated under realistic conditions)
- Not load testing (though realistic data volumes are used)

**What This IS:**
- Validation that milestone m01 works end-to-end as shipped
- Real user workflows through the complete stack (iOS app → REST API → Django → SQLite → geopy)
- Verification with actual services and data
- Final quality gate before milestone completion
- Consumer-grade quality validation (would you ship this to users?)
