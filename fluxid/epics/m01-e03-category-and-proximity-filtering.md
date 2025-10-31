---
id: m01-e03
title: Category and Proximity Filtering
milestone: m01
status: pending
tasks:
  - m01-e03-t01
  - m01-e03-t02
  - m01-e03-t03
  - m01-e03-t04
---

# Epic: Category and Proximity Filtering

## Overview
Provides a comprehensive two-tier filtering system that allows users to narrow flyer discovery by category tags (Events, Nightlife, Service) and proximity to their location. This epic enhances the core browsing experience with targeted discovery tools.

## Scope
- Two-tier filter UI component (category tags + relationship filters)
- Category tag filters (Events, Nightlife, Service) with multi-select OR logic
- "Near Me" proximity filter
- Filter state management and persistence during session
- Backend filter integration with API query parameters
- Visual feedback for active filters
- Filter reset functionality

## Success Criteria
- [ ] Users can select/deselect category tags with immediate feed update [Test: single category, multiple categories, all categories selected, all deselected, rapid toggling]
- [ ] Multi-select OR logic works correctly (show flyers matching ANY selected category) [Test: flyers with single category, multiple categories, edge cases with all categories]
- [ ] "Near Me" proximity filter shows only nearby flyers [Test: various distances, user location changes, no location permission, location unavailable]
- [ ] Active filters are visually indicated in the UI [Test: various filter combinations, clarity of selected state, accessibility]
- [ ] Filter changes update the feed in real-time [Test: smooth transitions, loading indicators, no flicker, maintain scroll position]
- [ ] Users can clear all filters to return to unfiltered feed [Test: clear button, reset state, feed restoration]
- [ ] Filter state persists during app session [Test: apply filters, navigate away, return to feed, filters still active]
- [ ] Filters combine correctly (category AND proximity) [Test: both filters active, one active, neither active, edge cases]
- [ ] UI handles no results gracefully [Test: filter combinations with zero matches, helpful empty state messaging]
- [ ] Performance remains smooth with filter changes [Test: rapid filter toggling, large result sets, filter transitions]

## Tasks
- Two-tier filter UI component design and layout (m01-e03-t01)
- Category tag filter implementation with multi-select logic (m01-e03-t02)
- Proximity "Near Me" filter implementation (m01-e03-t03)
- Filter state management and backend integration (m01-e03-t04)

## Dependencies
- m01-e01 (Backend Flyer API) - requires filter query support
- m01-e02 (Core Feed Display) - filters operate on existing feed UI
- m01-e05 (Location Services) - proximity filter requires user location

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
Filtering is a critical discovery tool that helps users find relevant flyers quickly. The two-tier system (category + proximity) provides both content-based and location-based narrowing.

**Key UX Decisions:**
- Multi-select OR logic for categories (more inclusive, better discovery)
- Visual distinction between category and proximity filters
- Immediate feed updates on filter changes (no "Apply" button)
- Clear active filter indicators
- Easy filter reset/clear mechanism

**Technical Considerations:**
- Filter state management (local state vs global state)
- API query parameter construction for combined filters
- Debouncing filter changes to avoid excessive API calls
- Maintain scroll position during filter updates when possible
- Handle edge cases: no location, no results, all filters active

**Filter Interaction Model:**
- Category tags: multi-select, OR logic (show flyers matching ANY selected)
- Proximity: single-select, binary (Near Me on/off)
- Combined: Category OR + Proximity AND (flyers match category OR and are nearby)
