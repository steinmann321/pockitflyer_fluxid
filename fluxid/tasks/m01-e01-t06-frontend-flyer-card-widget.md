---
id: m01-e01-t06
epic: m01-e01
title: Create Flyer Card Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyer Card Widget

## Objective
Build Flutter widget to display complete flyer information in card format for feed.

## Acceptance Criteria
- [ ] FlyerCard widget displays all required fields:
  - Creator info: profile picture (or default avatar), username
  - Image carousel: 1-5 images with swipe navigation and position indicator
  - Location: address text and distance (e.g., "1.2 km")
  - Title: bold, max 2 lines with ellipsis
  - Description: regular weight, max 4 lines with ellipsis, "Show more" link
  - Validity: formatted dates (e.g., "Valid until Dec 31, 2025")
- [ ] Visual design: card elevation, rounded corners, proper spacing, readable typography
- [ ] Tap anywhere on card navigates to flyer detail screen (placeholder for M01-E03)
- [ ] Loading state: shimmer effect while images load
- [ ] Error state: placeholder image if image fails to load
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders all fields correctly with various data
- Image carousel behavior (swipe, position indicator)
- Text truncation and ellipsis for long content
- Loading and error states
- Tap navigation (verify route push)
- Golden tests for visual consistency

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/flyer_card.dart`
- `pockitflyer_app/test/widgets/flyer_card_test.dart`
- `pockitflyer_app/test/golden/flyer_card/` (golden test images)

## Dependencies
- Frontend models: Flyer, Creator (see m01-e01-t07)

## Notes
- Use Flutter carousel_slider or similar package for image carousel
- Distance format: "X.X km" or "XXX m" if under 1 km
- Default avatar: use first letter of username in colored circle
- "Show more" link expands description inline (or navigates to detail view)
- Card is reusable across feed, search results, profile screens
