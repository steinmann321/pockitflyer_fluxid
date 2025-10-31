---
id: m01-e01
title: Backend Flyer API and Data Services
milestone: m01
status: pending
tasks:
  - m01-e01-t01
  - m01-e01-t02
  - m01-e01-t03
  - m01-e01-t04
  - m01-e01-t05
---

# Epic: Backend Flyer API and Data Services

## Overview
Provides the complete backend foundation for flyer discovery, including REST API endpoints, geocoding integration, smart ranking algorithm, and filter/search query handling. This epic delivers all backend services needed to support the anonymous flyer browsing experience.

## Scope
- Django REST API endpoints for flyer feed retrieval
- Geocoding service integration (geopy) for address-to-coordinates conversion
- Smart ranking algorithm balancing recency, proximity, and relevance
- Filter query handling (category tags, proximity)
- Search query processing
- Distance calculation utilities
- Public creator profile endpoint

## Success Criteria
- [ ] API returns flyer feed with complete data (creator, images, location, dates, description) [Test: various query parameters, pagination, empty results, malformed requests]
- [ ] Geocoding converts addresses to coordinates accurately [Test: various address formats, international addresses, invalid addresses, service failures with circuit breaker]
- [ ] Ranking algorithm orders flyers by recency, proximity, and relevance [Test: edge cases with same scores, distant vs recent, category relevance, boundary conditions]
- [ ] Category filter supports multi-select OR logic (Events, Nightlife, Service) [Test: single category, multiple categories, all categories, no categories]
- [ ] Proximity filter returns flyers within specified distance [Test: various distance thresholds, edge cases at boundaries, no location provided]
- [ ] Search query filters flyers in real-time [Test: partial matches, case sensitivity, special characters, empty search, very long search terms]
- [ ] Distance calculations are accurate within acceptable margin [Test: various coordinate pairs, edge cases near poles/dateline, same location, very distant locations]
- [ ] Public profile endpoint returns creator info with their flyers [Test: creator with multiple flyers, creator with no flyers, non-existent creator]
- [ ] API handles errors gracefully with appropriate status codes [Test: database failures, geocoding service timeouts, invalid parameters]
- [ ] Performance meets targets under realistic load [Test: concurrent requests, large result sets, complex filter combinations]

## Tasks
- Django models for Flyer, Creator, Location with proper indexes (m01-e01-t01)
- REST API endpoints with DRF serializers (m01-e01-t02)
- Geocoding service integration with circuit breaker (m01-e01-t03)
- Smart ranking algorithm implementation (m01-e01-t04)
- Filter, search, and distance calculation logic (m01-e01-t05)

## Dependencies
- Django REST Framework
- geopy library for geocoding
- SQLite database
- No dependencies on other epics (foundation epic)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
This is the foundation epic that all other epics depend on. It must be completed first to enable frontend development.

**Key Technical Decisions:**
- Use geopy for geocoding (external service integration)
- Implement circuit breaker pattern for geocoding resilience
- Store geocoordinates in database (no in-app geocoding on frontend)
- Use database indexing on all queried fields for performance
- Business logic validation at model layer, not in serializers

**Performance Considerations:**
- Pagination for large result sets
- Database query optimization with select_related/prefetch_related
- Caching strategy for frequently accessed data (consider for future)
