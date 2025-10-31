---
id: m02-e02
title: Flyer Creation & Publishing
milestone: m02
status: pending
tasks:
  - m02-e02-t01
  - m02-e02-t02
  - m02-e02-t03
  - m02-e02-t04
  - m02-e02-t05
  - m02-e02-t06
---

# Epic: Flyer Creation & Publishing

## Overview
Implements complete flyer creation and publishing workflow, enabling authenticated users to create digital flyers with images, text, categories, location, and dates. Flyers are immediately visible in the discovery feed (from m01) and respect the ranking algorithm. This epic delivers the core content creation capability that transforms the platform into a two-sided marketplace.

## Scope
- "Flyern" button in header (auth-protected, navigates to creation interface)
- Flyer creation UI with all required fields:
  - Image upload interface (1-5 images) with multi-select and preview
  - Title/caption text input
  - Two free-text information fields
  - Category tag selector (multi-select: Events, Nightlife, Service)
  - Address input field
  - Publication date picker
  - Expiration date picker
  - Publish button
- Backend flyer creation endpoint with validation
- Image upload and storage handling
- Geocoding integration: address → coordinates via geopy
- Flyer-user association
- Immediate integration with m01 discovery feed
- Ranking algorithm respect (recency, proximity, relevance)

## Success Criteria
- [ ] "Flyern" button in header navigates to creation interface (requires login) [Test: authenticated/unauthenticated states, navigation flow, login redirect]
- [ ] Users can upload 1-5 images with preview [Test: single image, multiple images, max limit, unsupported formats, size limits, preview rendering]
- [ ] All text input fields accept and validate data [Test: required fields, character limits, special characters, XSS attempts]
- [ ] Category selector allows multiple tag selection [Test: single category, multiple categories, no category, all categories]
- [ ] Address input sends address to backend for geocoding [Test: valid addresses, invalid addresses, geocoding success/failure, international addresses]
- [ ] Backend geocodes addresses to coordinates using geopy [Test: US addresses, international addresses, ambiguous addresses, geocoding service failures]
- [ ] Date pickers allow publication and expiration date selection [Test: valid date ranges, past dates, future dates, expiration before publication]
- [ ] Users can publish completed flyers [Test: all fields valid, missing required fields, image upload failures]
- [ ] Published flyers immediately appear in discovery feed [Test: verify feed integration, new flyer visibility, ranking position]
- [ ] Published flyers are visible to all users (anonymous and authenticated) [Test: logged out users see flyer, logged in users see flyer]
- [ ] Flyers respect ranking algorithm (recency, proximity, relevance) [Test: new flyer ranks higher, proximity affects ranking, category relevance]
- [ ] Backend validates flyer data and associates with creator [Test: user association, validation errors, malformed data]
- [ ] Image storage handles uploads securely [Test: file size limits, file type validation, storage path security, concurrent uploads]

## Tasks
- Frontend flyer creation UI components and form (m02-e02-t01)
- Frontend image upload with multi-select and preview (m02-e02-t02)
- Frontend category selector and date pickers (m02-e02-t03)
- Backend flyer creation endpoint with validation (m02-e02-t04)
- Backend image upload and storage (m02-e02-t05)
- Backend geocoding integration with geopy (m02-e02-t06)

## Dependencies
- Epic m02-e01 (authentication required for flyer creation)
- Milestone m01 (discovery feed must exist for flyer visibility)
- External service: geopy for geocoding
- Image storage solution (local filesystem or cloud storage)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
**Frontend Considerations:**
- Creation interface should be intuitive and polished (consumer-grade UX)
- Image upload should show progress indicators
- Form validation should provide clear error messages
- Date pickers should prevent invalid date ranges
- Category selector should be easy to use (chips, checkboxes, or similar)
- "Flyern" button should only be visible when authenticated

**Backend Architecture:**
- RESTful endpoint: POST /api/flyers/
- JWT authentication required
- Multipart form data for image uploads
- Geocoding via geopy (address → lat/lng)
- Flyer model fields: creator (FK to User), title, info_field_1, info_field_2, categories (M2M), address, lat, lng, publication_date, expiration_date, images (M2M or JSON)
- Validation: required fields, date logic, image limits, XSS protection

**Image Storage:**
- Validate file types (JPEG, PNG, WebP)
- Enforce size limits (e.g., 5MB per image)
- Generate unique filenames to prevent collisions
- Store securely (outside web root or with proper access controls)
- Consider image optimization (resize, compress) for performance

**Geocoding Integration:**
- Use geopy library with appropriate geocoding service (Nominatim, Google, etc.)
- Handle geocoding failures gracefully (retry, fallback, user notification)
- Cache geocoding results to reduce API calls
- Implement circuit breaker pattern for resilience
- Store both address (text) and coordinates (lat/lng)

**Feed Integration:**
- Published flyers immediately queryable in m01 feed endpoint
- Ranking algorithm considers:
  - Recency: publication_date (newer = higher)
  - Proximity: distance from user location to flyer lat/lng
  - Relevance: category match with user interests (future enhancement)
- Flyers respect expiration_date (not shown after expiration)

This epic maps to milestone m02 success criteria lines 18-26, 28-30 and requirement sections:
- Flyer Creation & Management - Creation (refined-product-analysis.md lines 183-186)
- Discovery & Browse (refined-product-analysis.md lines 128-139) for feed integration
