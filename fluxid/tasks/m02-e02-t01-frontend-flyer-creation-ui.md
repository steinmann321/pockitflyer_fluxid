---
id: m02-e02-t01
title: Frontend Flyer Creation UI Components and Form
epic: m02-e02
milestone: m02
status: pending
---

# Task: Frontend Flyer Creation UI Components and Form

## Context
Part of Flyer Creation & Publishing (m02-e02) in Milestone m02 (Authenticated User Experience).

Implements the main flyer creation interface accessible via the "Flyern" button in the app header. This task creates the foundational UI structure, navigation flow, authentication protection, and basic form layout that will be enhanced with image upload (t02) and category/date pickers (t03).

## Implementation Guide for LLM Agent

### Objective
Create auth-protected flyer creation screen with navigation, header button, and form structure for title, info fields, address, and publish action.

### Steps

1. Create "Flyern" header button component
   - Add button to app header/navigation bar (locate existing header component)
   - Button text: "Flyern"
   - Style: Primary CTA button style (match app design system)
   - Visibility: Only show when user is authenticated (check auth state)
   - Action: Navigate to flyer creation screen

2. Implement authentication guard for flyer creation route
   - Create route guard/middleware that checks authentication state
   - If unauthenticated: redirect to login screen with return URL parameter
   - After successful login: redirect back to flyer creation screen
   - If authenticated: allow access to creation screen

3. Create flyer creation screen component
   - New screen: `FlyerCreationScreen` or similar
   - App bar with title "Create Flyer" and back button
   - Scrollable form container
   - Bottom action bar with "Publish" button

4. Implement form structure with text input fields
   ```dart
   // Pseudo-structure
   FlyerCreationForm:
     - Title field (required, max 100 chars)
       * Label: "Title"
       * Placeholder: "Enter flyer title"
       * Validation: required, 1-100 characters

     - Info field 1 (optional, max 500 chars)
       * Label: "Information 1"
       * Placeholder: "Additional information"
       * Multi-line text input
       * Character counter

     - Info field 2 (optional, max 500 chars)
       * Label: "Information 2"
       * Placeholder: "More information"
       * Multi-line text input
       * Character counter

     - Address field (required)
       * Label: "Address"
       * Placeholder: "Enter event address"
       * Validation: required, max 200 characters

     - Placeholder sections for:
       * Image upload (will be implemented in t02)
       * Category selector (will be implemented in t03)
       * Date pickers (will be implemented in t03)
   ```

5. Implement form state management
   - Use Flutter state management (Provider, Riverpod, or existing pattern)
   - Track form field values
   - Track form validation state
   - Track form dirty state (unsaved changes)

6. Implement form validation logic
   - Validate title: required, 1-100 characters
   - Validate info fields: optional, max 500 characters each
   - Validate address: required, max 200 characters
   - Display inline validation errors below fields
   - Disable publish button until form is valid

7. Implement publish button handler (stub)
   - Button enabled only when form is valid
   - On tap: show loading indicator (actual API call in t04)
   - Stub implementation: log form data to console
   - Success state: navigate back to feed (will be replaced with API call)
   - Error state: show error message (will be implemented with actual API)

8. Add unsaved changes warning
   - If form is dirty and user navigates back: show confirmation dialog
   - Dialog: "Discard changes?" with Cancel/Discard actions
   - Prevent accidental data loss

9. Create form widget tests
   - Test: Screen renders with all form fields
   - Test: Title validation (empty, too long, valid)
   - Test: Info field character limits
   - Test: Address validation
   - Test: Publish button disabled when invalid
   - Test: Publish button enabled when valid
   - Test: Unsaved changes dialog appears on back navigation

10. Create navigation integration tests
    - Test: "Flyern" button visible when authenticated
    - Test: "Flyern" button hidden when not authenticated
    - Test: Navigation to creation screen when button tapped (authenticated)
    - Test: Redirect to login when accessing creation route (unauthenticated)
    - Test: Return to creation screen after login redirect

### Acceptance Criteria
- [ ] "Flyern" button appears in header when user is authenticated [Test: login, verify button visible]
- [ ] "Flyern" button hidden when user is not authenticated [Test: logout, verify button hidden]
- [ ] Button navigates to flyer creation screen [Test: tap button, verify navigation]
- [ ] Unauthenticated access redirects to login [Test: direct route access, verify redirect with return URL]
- [ ] After login, user returns to creation screen [Test: complete login redirect flow]
- [ ] Form displays title, info1, info2, address fields [Test: render form, verify all fields present]
- [ ] Title field validates required and character limit [Test: empty, 101 chars, valid]
- [ ] Info fields enforce 500 character limit [Test: 501 chars, 500 chars]
- [ ] Address field validates required [Test: empty, valid]
- [ ] Publish button disabled when form invalid [Test: empty required fields]
- [ ] Publish button enabled when form valid [Test: all required fields filled]
- [ ] Unsaved changes warning shows on back navigation [Test: modify form, tap back]
- [ ] Widget tests pass with ≥90% coverage on new components
- [ ] Integration tests pass for navigation flow

### Files to Create/Modify
- `pockitflyer_app/lib/screens/flyer_creation_screen.dart` - NEW: main creation screen
- `pockitflyer_app/lib/widgets/flyer_creation_form.dart` - NEW: form widget
- `pockitflyer_app/lib/widgets/app_header.dart` - MODIFY: add "Flyern" button
- `pockitflyer_app/lib/routes/app_router.dart` - MODIFY: add creation route with auth guard
- `pockitflyer_app/lib/providers/flyer_creation_provider.dart` - NEW: form state management
- `pockitflyer_app/test/widgets/flyer_creation_form_test.dart` - NEW: widget tests
- `pockitflyer_app/test/integration/flyer_creation_flow_test.dart` - NEW: navigation tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Widget tests**:
  - Form rendering with all fields
  - Validation logic (title, info fields, address)
  - Button enable/disable states
  - Character counters
  - Unsaved changes dialog

- **Integration tests**:
  - Complete navigation flow (header button → creation screen)
  - Authentication guard (redirect to login, return after auth)
  - Form submission (stub, logs data)
  - Back navigation with/without unsaved changes

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter and project conventions
- [ ] No console errors or warnings
- [ ] Form fields follow app design system
- [ ] Changes committed with `m02-e02-t01` reference
- [ ] Ready for t02 (image upload) and t03 (categories/dates) integration

## Dependencies
- Requires: m02-e01 (authentication system, JWT, auth state management)
- Requires: m01 (app header/navigation structure, feed screen for post-publish navigation)
- Blocks: m02-e02-t02 (image upload needs form container)
- Blocks: m02-e02-t03 (category/date pickers need form container)

## Technical Notes
- **Authentication guard**: Use existing auth state provider from m02-e01
- **State management**: Follow project's existing pattern (Provider/Riverpod)
- **Form validation**: Use Flutter Form widget or custom validation
- **Routing**: Use existing router (go_router, Navigator 2.0, or custom)
- **Design system**: Match existing app styling (buttons, inputs, colors, spacing)
- **Accessibility**: Ensure labels, hints, and error messages are screen-reader friendly

**Form UX Guidelines**:
- Clear visual hierarchy (title at top, publish at bottom)
- Inline validation errors (below each field)
- Character counters for limited fields
- Auto-focus on title field when screen loads
- Smooth keyboard handling (scroll to focused field)
- Loading state on publish button

**Navigation Pattern**:
- Return URL pattern for login redirect: `/create-flyer` → `/login?returnUrl=/create-flyer` → `/create-flyer`
- Use stack navigation (allow back navigation to previous screen)
- After successful publish: pop to feed screen (not back in stack)

## References
- Flutter Form and validation: https://docs.flutter.dev/cookbook/forms/validation
- Navigation and routing patterns from existing app structure
- Authentication state management from m02-e01
- App design system and component library (if exists in codebase)
