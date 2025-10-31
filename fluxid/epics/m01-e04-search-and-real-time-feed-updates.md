---
id: m01-e04
title: Search and Real-time Feed Updates
milestone: m01
status: pending
tasks:
  - m01-e04-t01
  - m01-e04-t02
  - m01-e04-t03
---

# Epic: Search and Real-time Feed Updates

## Overview
Adds real-time search capability to the header and implements pull-to-refresh for manual feed updates. This epic completes the discovery toolkit by enabling users to find specific flyers through text search and refresh their feed for the latest content.

## Scope
- Header search field with real-time filtering
- Search query processing (filters current feed results)
- Pull-to-refresh implementation for manual feed updates
- Search result highlighting and empty states
- Search state management and clearing
- Backend search integration

## Success Criteria
- [ ] Search field in header is always accessible [Test: various scroll positions, feed states, visual prominence]
- [ ] Search filters flyers in real-time as user types [Test: partial matches, case insensitivity, special characters, emoji, very long queries]
- [ ] Search matches flyer title, description, and creator name [Test: matches in each field, multiple matches, no matches]
- [ ] Search updates feed immediately without full page refresh [Test: smooth transitions, loading indicators, maintain UI state]
- [ ] Pull-to-refresh manually updates feed with new content [Test: new flyers available, no new flyers, refresh during active search/filters]
- [ ] Empty search shows all flyers (returns to unfiltered state) [Test: clear search, delete all characters, cancel search]
- [ ] Search combines correctly with active filters [Test: search + category filter, search + proximity filter, search + both filters]
- [ ] Search handles no results gracefully [Test: zero matches, helpful empty state messaging, suggest clearing filters]
- [ ] Search clears when user dismisses keyboard or taps clear [Test: clear button, keyboard dismiss, explicit cancel]
- [ ] Performance remains smooth during search [Test: rapid typing, large result sets, search while scrolling, debouncing]

## Tasks
- Header search field UI component (m01-e04-t01)
- Real-time search filtering logic and backend integration (m01-e04-t02)
- Pull-to-refresh implementation with state management (m01-e04-t03)

## Dependencies
- m01-e01 (Backend Flyer API) - requires search query support
- m01-e02 (Core Feed Display) - search operates on feed UI
- m01-e03 (Category and Proximity Filtering) - search combines with filters

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
Search is the final piece of the discovery toolkit. Unlike filters which narrow by category/location, search enables users to find specific content through text matching.

**Key UX Decisions:**
- Real-time search (no "Search" button, updates as user types)
- Search field in persistent header (always accessible)
- Clear visual feedback for active search
- Easy search clearing/canceling
- Pull-to-refresh for manual content updates

**Technical Considerations:**
- Debounce search input to avoid excessive API calls (300-500ms)
- Search should filter current feed results efficiently
- Combine search with existing filter state correctly
- Handle search string encoding/escaping properly
- Consider search performance with large result sets

**Search Behavior:**
- Searches flyer title, description, and creator name
- Case-insensitive matching
- Partial match support (substring matching)
- Combines with active category/proximity filters (AND logic)
- Empty search string returns to current filter state (no search applied)

**Pull-to-Refresh:**
- Standard iOS pattern for manual content refresh
- Shows loading indicator during refresh
- Updates feed with latest flyers from backend
- Maintains current filter/search state after refresh
- Provides haptic feedback on refresh trigger
