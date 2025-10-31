---
id: m01
title: Anonymous Discovery - Browse and Discover Local Flyers
status: pending
---

# Milestone: Anonymous Discovery - Browse and Discover Local Flyers

## Deliverable
Users can browse, filter, search, and discover local digital flyers without authentication. The home screen provides a complete discovery experience with a smart-ranked feed, multi-tier filtering system (category tags + Near Me), in-place search, and full flyer details displayed in cards. Users can view creator profiles and see distance to each flyer based on their device location. All functionality works with real backend APIs, database, and geocoding integration.

## Success Criteria
- [ ] Users can browse a feed of local flyers with smart ranking (recency, proximity, relevance) - complete UI implementation with backend API integration
- [ ] Users can filter flyers by category tags (Events, Nightlife, Service) using OR logic with multi-select - UI filters connected to backend query APIs
- [ ] Users can use "Near Me" filter to see nearby flyers based on device location - frontend location services integrated with backend distance calculation
- [ ] Users can search flyers in real-time using in-place header search - search UI updates feed via backend search API
- [ ] Users can pull-to-refresh to manually update the feed with new content - UI gesture triggers backend API call
- [ ] Each flyer card displays complete information: creator identity, image carousel (1-5 images), location with distance, title, description, validity period - all data from backend models
- [ ] Users can tap creator name/avatar to navigate to public profile page showing profile picture, name, and creator's flyers - profile UI with backend user API
- [ ] Users can open flyer location in device's native map app - frontend integration with device maps
- [ ] All flyer locations show accurate distance from user's current position - backend geocoding service converts addresses to coordinates, frontend calculates distance
- [ ] Complete UI implementation for all user workflows - polished, production-ready interface
- [ ] Full backend integration with Django REST API - no stub APIs or mocked data
- [ ] Database models for flyers and users with proper indexing - SQLite with migrations
- [ ] External geocoding integration (geopy) for address-to-coordinate conversion
- [ ] All flows are polished and production-ready - consumer-grade quality
- [ ] Can be deployed independently - standalone discovery platform
- [ ] Requires no additional milestones to be useful - immediate user value

## Validation Questions
**Before marking this milestone complete, answer:**
- [ ] Can a real user perform complete workflows with only this milestone? (browse, filter, search, view profiles)
- [ ] Is it polished enough to ship publicly? (production-ready UI and backend)
- [ ] Does it solve a real problem end-to-end? (discovering local flyers)
- [ ] Does it include both complete UI and functional backend integration? (yes - full stack)
- [ ] Can it run independently without waiting for other milestones? (yes - anonymous browsing is self-contained)
- [ ] Would you personally use this if it were released today? (yes - valuable discovery platform)

## Notes
- This milestone establishes the core platform infrastructure (backend API, database, geocoding)
- All subsequent milestones build on this foundation
- Anonymous browsing is the primary user entry point - must be highly polished
- Backend handles all geocoding - frontend only works with coordinates
- Smart ranking algorithm balances recency, proximity, and relevance
- Pull-to-refresh is the only feed update mechanism (no auto-refresh)
