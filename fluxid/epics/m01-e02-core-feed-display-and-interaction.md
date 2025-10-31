---
id: m01-e02
title: Core Feed Display and Interaction
milestone: m01
status: pending
tasks:
  - m01-e02-t01
  - m01-e02-t02
  - m01-e02-t03
  - m01-e02-t04
  - m01-e02-t05
---

# Epic: Core Feed Display and Interaction

## Overview
Delivers the fundamental flyer browsing experience with infinite scroll feed, complete flyer cards, and image carousels. This epic establishes the core UI foundation that enables users to discover and view local flyers.

## Scope
- Persistent header with PokitFlyer branding and navigation structure
- Infinite scroll feed with pull-to-refresh functionality
- Flyer card component displaying all required elements:
  - Creator name and avatar
  - Image carousel (1-5 images) with dot indicators
  - Location with distance display
  - Title and description
  - Validity dates
  - Interactive buttons (location, creator profile)
- Image carousel with swipe gestures and dot indicators
- Backend API integration for flyer data
- Basic navigation structure and routing

## Success Criteria
- [ ] Users see a scrolling feed of flyers immediately on app launch [Test: fresh install, existing user, various data volumes, empty state]
- [ ] Infinite scroll loads additional flyers as user scrolls [Test: smooth scrolling, pagination boundaries, end of results, loading indicators]
- [ ] Pull-to-refresh updates feed with new content [Test: new flyers available, no new flyers, refresh during scroll, network failures]
- [ ] Each flyer card displays all required elements accurately [Test: various data combinations, missing optional fields, very long text, special characters]
- [ ] Image carousels support 1-5 images with swipe gestures [Test: single image, multiple images, rapid swipes, edge images, dot indicator sync]
- [ ] Location displays accurate distance from user [Test: various distances, no user location, distance formatting (m/km)]
- [ ] Creator avatar and name are tappable to navigate to profile [Test: tap response, navigation animation, back navigation]
- [ ] Location button opens device's native map app [Test: iOS Maps integration, address accuracy, error handling if no map app]
- [ ] Feed handles loading and error states gracefully [Test: slow network, no network, server errors, timeout scenarios]
- [ ] UI is polished and production-ready [Test: visual design consistency, animations, responsiveness on various iOS devices]

## Tasks
- Flutter app structure and navigation setup (m01-e02-t01)
- Persistent header component (m01-e02-t02)
- Infinite scroll feed with pull-to-refresh (m01-e02-t03)
- Flyer card component with all elements (m01-e02-t04)
- Image carousel with swipe and dot indicators (m01-e02-t05)

## Dependencies
- m01-e01 (Backend Flyer API) - requires API endpoints for data
- iOS platform capabilities (map integration, location services)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
This epic establishes the core browsing experience. Users must be able to view flyers in a scrollable feed before filters, search, or other discovery features are added.

**Key UI/UX Decisions:**
- Pull-to-refresh for manual feed updates (standard iOS pattern)
- Infinite scroll for seamless browsing
- Image carousel with dot indicators for multi-image flyers
- Tappable creator info for profile navigation
- Distance displayed on flyer card (requires user location)

**Technical Considerations:**
- Use Flutter ListView.builder for efficient infinite scroll
- Implement proper image loading/caching for performance
- Handle various screen sizes (iPhone SE to iPhone Pro Max)
- Ensure smooth 60fps scrolling and swipe gestures
- Loading states should be clear but non-intrusive
