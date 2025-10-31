---
id: m01-e02
title: User Filters and Searches Flyers
milestone: m01
status: pending
---

# Epic: User Filters and Searches Flyers

## Overview
Users refine the flyer feed using category filters (Events, Nightlife, Service), Near Me location filter, and real-time in-place search. Filters use OR logic with multi-select capability. Search updates the feed in real-time as users type. All filtering and searching is powered by backend API endpoints with efficient database queries. This epic delivers the complete discovery refinement experience.

## Scope
- Category filter UI with multi-select (Events, Nightlife, Service)
- Near Me toggle filter based on proximity threshold
- In-place header search with real-time results
- Filter combination logic (category OR + Near Me AND + search)
- Backend API endpoints for filtered/searched flyer queries
- Efficient database queries with compound indexes
- Filter state management in frontend
- Search debouncing to reduce API calls

## Success Criteria
- [ ] Users can select/deselect category filters with immediate feed update [Test: single category, multiple categories, all categories, none selected]
- [ ] Category filters use OR logic correctly [Test: Events OR Nightlife shows both, verify results contain only selected categories]
- [ ] Near Me filter shows only flyers within proximity threshold [Test: various distance thresholds, edge cases at boundary, no nearby flyers]
- [ ] In-place search updates feed as user types [Test: partial matches, no matches, special characters, empty search]
- [ ] Filter combinations work correctly [Test: category + Near Me, category + search, Near Me + search, all three combined]
- [ ] Search is debounced to avoid excessive API calls [Test: rapid typing, verify API call count, debounce timing]
- [ ] Filter state persists during app session [Test: navigate away and back, pull-to-refresh maintains filters]
- [ ] Backend queries execute efficiently with compound indexes [Test: filtered queries < 500ms, various filter combinations, 1000+ flyers]
- [ ] Search matches against title and description fields [Test: title matches, description matches, case insensitivity, partial word matches]
- [ ] Feed shows appropriate empty states for no results [Test: no matches for filters, no matches for search, no nearby flyers]

## Dependencies
- Epic m01-e01 (requires flyer feed to be functional)
- Backend database must support efficient compound indexes for category + location + text search

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Category filters use OR logic: selecting multiple categories shows flyers matching ANY selected category
- Near Me filter uses AND logic: combines with category filters to narrow results
- Search uses AND logic: combines with all active filters
- Proximity threshold for Near Me filter: 5km radius (configurable)
- Search debounce delay: 300ms after last keystroke
- Backend must use full-text search or LIKE queries for search functionality
- Database compound indexes needed: (category, location), (location, valid_until), (category, location, valid_until)
- Filter state is session-only (does not persist across app restarts)
