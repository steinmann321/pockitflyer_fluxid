---
id: m01-e04-t01
title: Header Search Field UI Component
epic: m01-e04
milestone: m01
status: complete
---

# Task: Header Search Field UI Component

## Context
Part of Search and Real-time Feed Updates (m01-e04) in Milestone 1 (m01).

Creates a persistent search field in the app header that is always accessible to users regardless of scroll position or feed state. This provides the UI foundation for real-time search functionality.

## Implementation Guide for LLM Agent

### Objective
Create a search input field component in the app header with clear/cancel functionality, proper keyboard handling, and visual feedback for active search state.

### Steps
1. Create search field widget component
   - Create `pockitflyer_app/lib/widgets/search_field.dart`
   - Implement `SearchField` widget as a StatefulWidget
   - Add TextEditingController for input management
   - Add FocusNode for keyboard focus management
   - Include clear button (X icon) visible when text is entered
   - Add search icon as leading widget
   - Style with Flutter Material design (outlined input field)
   - Set hint text: "Search flyers..."
   - Implement onChanged callback to emit search query changes
   - Implement onClear callback for clear button tap
   - Add debounce logic (300ms delay) before calling onChanged to avoid excessive updates

2. Integrate search field into app header
   - Locate the main app scaffold/header in `pockitflyer_app/lib/main.dart` or create header widget
   - If no header exists, create `pockitflyer_app/lib/widgets/app_header.dart` with AppBar
   - Add SearchField widget to the header (in title or as flexible space)
   - Ensure header is persistent (not scrollable away)
   - Position search field prominently for easy access

3. Implement keyboard handling
   - Add dismiss keyboard on clear button tap
   - Add dismiss keyboard when user taps outside search field
   - Handle iOS keyboard "Done" button to dismiss keyboard
   - Ensure smooth keyboard animation transitions

4. Add visual feedback for search state
   - Show clear button only when text is entered
   - Add visual indicator when search is active (e.g., border color change)
   - Ensure search field is visually prominent in header
   - Add smooth transitions for UI state changes

5. Create widget tests
   - Test rendering with empty and filled text
   - Test clear button visibility (hidden when empty, shown when text entered)
   - Test onChanged callback is triggered after debounce delay
   - Test onClear callback is triggered on clear button tap
   - Test keyboard dismiss on clear
   - Test debounce prevents excessive callback calls

### Acceptance Criteria
- [x] Search field renders in app header and is always visible [Test: scroll feed, navigate, check visibility]
- [x] Search field accepts text input and displays hint text [Test: type text, verify display, verify hint]
- [x] Clear button appears when text is entered and disappears when empty [Test: type text, verify button, clear text, verify hidden]
- [x] Clear button clears text and dismisses keyboard [Test: tap clear, verify text cleared, verify keyboard dismissed]
- [x] onChanged callback fires after 300ms debounce delay [Test: rapid typing, verify callback timing]
- [x] Keyboard dismisses when user taps outside search field [Test: focus field, tap outside, verify keyboard hidden]
- [x] Search field visual state changes when active [Test: focus field, verify visual indicator]
- [x] Widget tests pass with >90% coverage

### Files to Create/Modify
- `pockitflyer_app/lib/widgets/search_field.dart` - NEW: search input widget component
- `pockitflyer_app/lib/widgets/app_header.dart` - NEW: app header widget (if needed)
- `pockitflyer_app/lib/main.dart` - MODIFY: integrate search field into app scaffold/header
- `pockitflyer_app/test/widgets/search_field_test.dart` - NEW: widget tests for search field

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit test**: Debounce logic, text controller management, callback triggering
- **Widget test**: Search field rendering, clear button visibility, keyboard interactions, visual state changes

### Definition of Done
- [x] Code written and passes all tests
- [x] Code follows project conventions (Flutter/Dart style guide)
- [x] No console errors or warnings
- [x] Widget properly integrated into app header
- [x] Changes committed with reference to task ID
- [x] Ready for dependent tasks to use (m01-e04-t02 can connect search field to filtering logic)

## Dependencies
- Requires: Flutter project structure from m01-e02 (Core Feed Display)
- Blocks: m01-e04-t02 (Real-time search filtering logic)

## Technical Notes
- Use Flutter's `TextField` widget as base component
- Implement debounce using `Timer` to avoid excessive callback calls during rapid typing
- Use `FocusNode` to detect when field loses focus for keyboard dismissal
- Consider using `GestureDetector` wrapper to dismiss keyboard on tap outside
- Follow Material Design guidelines for search field styling
- Ensure search field takes appropriate space in header without crowding other UI elements
- Test on iOS to ensure keyboard behavior matches platform conventions

## References
- Flutter TextField documentation: https://api.flutter.dev/flutter/material/TextField-class.html
- Flutter Debounce pattern: https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart
- Material Design search patterns: https://m3.material.io/components/search/overview
