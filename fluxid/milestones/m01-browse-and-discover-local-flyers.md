---
id: m01
title: Users can browse and discover local flyers
status: pending
---

# Milestone: Users can browse and discover local flyers

## Deliverable
Anonymous users can open PokitFlyer and immediately browse a feed of local digital flyers, filter by categories and proximity, view complete flyer information including images and locations, and open locations in their device's map app. This delivers the core discovery experience that replaces traditional paper flyer browsing with a digital, location-aware alternative.

## Success Criteria
- [ ] Users can launch the app and see a scrolling feed of local flyers without creating an account
- [ ] Each flyer card displays: creator info, image carousel (1-5 images), location with distance, title, description, validity dates, and interactive buttons
- [ ] Users can filter flyers by category tags (Events, Nightlife, Service) with multi-select OR logic
- [ ] Users can filter flyers by proximity using "Near Me" filter
- [ ] Users can search flyers in real-time using the header search field (filters current feed)
- [ ] Users can pull-to-refresh to manually update the feed with new content
- [ ] Feed uses smart ranking algorithm balancing recency, proximity, and relevance
- [ ] Users can swipe through image carousels on flyer cards
- [ ] Users can tap location button to open the flyer's address in device's native map app
- [ ] Users can tap creator name/avatar to view creator's public profile page showing their flyers
- [ ] Backend API provides flyer data with geocoordinates (no in-app geocoding)
- [ ] Location permissions work correctly and distance calculations are accurate
- [ ] Complete UI implementation for all user workflows
- [ ] Full backend integration (no stub APIs or mocked data)
- [ ] All flows are polished and production-ready
- [ ] Can be deployed independently
- [ ] Requires no additional milestones to be useful

## Validation Questions
**Before marking this milestone complete, answer:**
- [x] Can a real user perform complete workflows with only this milestone? Yes - full browse, filter, view, navigate workflow
- [x] Is it polished enough to ship publicly? Yes - complete discovery experience
- [x] Does it solve a real problem end-to-end? Yes - users can find and explore local services/events digitally
- [x] Does it include both complete UI and functional backend integration? Yes - feed UI, filter UI, search UI, profile UI, backend API with geocoding
- [x] Can it run independently without waiting for other milestones? Yes - anonymous browsing is self-contained
- [x] Would you personally use this if it were released today? Yes - valuable local discovery tool

## Notes
This milestone establishes the core value proposition of PokitFlyer: immediate access to local information without barriers. By enabling anonymous browsing, we remove friction for new users while demonstrating the platform's value. The complete UI and backend integration includes:

**Frontend Components:**
- Persistent header with branding, search, and navigation
- Two-tier filter system (category tags + relationship filters)
- Infinite scroll feed with pull-to-refresh
- Flyer cards with all specified elements and interactions
- Image carousel with dot indicators
- Public profile page view
- Native map integration

**Backend Components:**
- REST API for flyer feed with smart ranking
- Geocoding service integration (address → coordinates)
- Distance calculation from user location
- Filter and search query handling
- Public profile endpoint with user's flyers

**Key Dependencies:**
- Device location permissions
- Backend geocoding service (geopy)
- Native map app integration

This milestone maps to requirements in refined-product-analysis.md sections:
- Home Screen - Discovery Interface (lines 63-76)
- UI Layout Understanding (lines 233-293)
- Feed Ranking Algorithm (lines 123-128)
- Filter Interaction Logic (lines 130-138)
- Search Behavior (lines 147-154)
- Card Interaction Model (lines 156-165)
