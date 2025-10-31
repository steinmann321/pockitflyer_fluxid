---
id: m01-e03-t02
title: Filter UI Component
epic: m01-e03
milestone: m01
status: pending
---

# Task: Filter UI Component

## Context
Part of Category and Proximity Filtering (m01-e03) in Browse and Discover Local Flyers (m01).

Creates the two-tier filter UI component (category tags + proximity toggle) that allows users to visually select filters and see active filter states. This component will be integrated into the existing feed UI from m01-e02.

## Implementation Guide for LLM Agent

### Objective
Build a polished, interactive filter UI component with category tag buttons (Events, Nightlife, Service) and proximity toggle ("Near Me"), including visual active states and clear/reset functionality.

### Steps
1. Create filter component widget structure
   - Create `pockitflyer_app/lib/features/feed/widgets/flyer_filter_bar.dart`
   - Two-tier layout: Category tags row + Proximity toggle row
   - Use Flutter Row/Column for layout
   - Component accepts callbacks: `onCategoryChanged(List<String> categories)`, `onProximityChanged(bool enabled)`

2. Implement category tag buttons
   - Three pill-shaped buttons: "Events", "Nightlife", "Service"
   - Multi-select behavior: tap to toggle on/off
   - Visual states:
     - **Inactive**: light gray background, dark text, thin border
     - **Active**: brand color background, white text, no border
   - Use Flutter `FilterChip` or custom `Container` with `InkWell` for tap handling
   - Store selected categories in local widget state (List<String>)

3. Implement proximity toggle button
   - Single pill-shaped toggle: "Near Me" with location icon
   - Binary state: on/off
   - Visual states:
     - **Inactive**: light gray background, dark text, location icon outlined
     - **Active**: brand color background, white text, location icon filled
   - Use Flutter `FilterChip` or custom toggle widget
   - Store proximity state in local widget state (bool)

4. Add clear/reset button
   - Small "Clear All" text button on the right side of filter bar
   - Only visible when at least one filter is active
   - Tap to reset all filters (categories + proximity) to inactive
   - Trigger callbacks with empty/false values

5. Implement callback logic
   - When category button tapped: add/remove from selected list, call `onCategoryChanged(selectedCategories)`
   - When proximity toggle tapped: flip boolean, call `onProximityChanged(proximityEnabled)`
   - When clear button tapped: reset all states, call both callbacks with empty/false values
   - Callbacks trigger parent component (feed) to update data

6. Add visual polish
   - Smooth tap animations (scale or color transitions)
   - Ripple effects on buttons (Material InkWell)
   - Proper spacing between elements (8-16px gaps)
   - Responsive layout for different screen sizes (iPhone SE to Pro Max)
   - Accessibility: semantic labels for screen readers

7. Integrate filter bar into feed screen
   - Modify `pockitflyer_app/lib/features/feed/screens/feed_screen.dart`
   - Add `FlyerFilterBar` widget above the infinite scroll list
   - Position: sticky below the header (scrolls with feed or fixed, UX decision)
   - Wire callbacks to state management (will be implemented in m01-e03-t03, for now just log or use placeholder)

8. Create widget tests
   - **Widget tests** (8-10 tests):
     - Render filter bar with all elements visible
     - Tap category button toggles active state visually
     - Multi-select categories (tap multiple, verify all active)
     - Tap proximity toggle changes state visually
     - Clear button only visible when filters active
     - Clear button resets all filters
     - Callbacks triggered with correct values
     - Visual state changes (colors, icons) verified
     - Accessibility labels present
     - Responsive layout on small/large screens

9. Create data models for filter state (if needed)
   - Create `pockitflyer_app/lib/features/feed/models/filter_state.dart`
   - Freezed model: `FilterState(List<String> categories, bool nearMe)`
   - Immutable model for state management integration (used in m01-e03-t03)

### Acceptance Criteria
- [ ] Filter bar displays category tags (Events, Nightlife, Service) and proximity toggle [Test: visual inspection on simulator]
- [ ] Category buttons toggle on/off with multi-select [Test: tap multiple categories, verify all can be active simultaneously]
- [ ] Active filters have distinct visual appearance [Test: active vs inactive states clearly different]
- [ ] Proximity toggle changes state on tap [Test: tap, verify visual change]
- [ ] Clear button resets all filters [Test: activate filters, tap clear, verify all inactive]
- [ ] Clear button only visible when filters active [Test: no filters → hidden, any filter active → visible]
- [ ] Callbacks triggered with correct values [Test: widget tests verify callback parameters]
- [ ] UI is polished and production-ready [Test: animations smooth, spacing consistent, accessibility labels present]
- [ ] All widget tests pass with >85% coverage

### Files to Create/Modify
- `pockitflyer_app/lib/features/feed/widgets/flyer_filter_bar.dart` - NEW: filter UI component
- `pockitflyer_app/lib/features/feed/models/filter_state.dart` - NEW: filter state data model (Freezed)
- `pockitflyer_app/lib/features/feed/screens/feed_screen.dart` - MODIFY: integrate filter bar into feed UI
- `pockitflyer_app/test/features/feed/widgets/flyer_filter_bar_test.dart` - NEW: widget tests for filter bar
- `pockitflyer_app/lib/core/theme/app_colors.dart` - MODIFY: add filter colors if needed (may already exist)

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/widget tests here.

- **Widget tests**: Filter bar rendering, tap interactions, state changes, callbacks, visual states, accessibility, responsive layout

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter/Riverpod conventions
- [ ] No console errors or warnings
- [ ] UI matches design specifications (polished, production-ready)
- [ ] Changes committed with reference to task ID (m01-e03-t02)
- [ ] Ready for state management integration (m01-e03-t03)

## Dependencies
- Requires: m01-e02-t02 (Feed screen UI exists), m01-e02-t03 (Feed structure for integration)
- Blocks: m01-e03-t03 (Filter State Management)

## Technical Notes
- Use Flutter `FilterChip` for quick implementation or custom `Container` + `InkWell` for more control
- Consider using `AnimatedContainer` for smooth color transitions on tap
- Filter bar should be visually distinct from header but integrated into feed layout
- Position decision: Fixed below header vs. scrolls with feed (recommend fixed for easy access)
- Brand color reference: check `app_colors.dart` for primary color (or define if missing)
- Category values must match backend API: "events", "nightlife", "service" (lowercase)
- Proximity filter will need location permission (handled in m01-e05, for now assume permission granted)

## References
- Flutter FilterChip: https://api.flutter.dev/flutter/material/FilterChip-class.html
- Flutter InkWell (ripple effects): https://api.flutter.dev/flutter/material/InkWell-class.html
- Freezed for immutable models: https://pub.dev/packages/freezed
- Existing feed screen implementation (m01-e02)
- Material Design filter patterns: https://m3.material.io/components/chips/overview
