---
id: m01-e02-t02
title: Persistent Header Component
epic: m01-e02
milestone: m01
status: pending
---

# Task: Persistent Header Component

## Context
Part of Core Feed Display and Interaction (m01-e02) in Browse and Discover Local Flyers (m01).

Creates the fixed header that remains visible during scrolling, providing access to core navigation: app branding, search, flyer creation, and user authentication/profile. This header is the primary navigation mechanism and must remain accessible at all times.

## Implementation Guide for LLM Agent

### Objective
Build a persistent, fixed header component displaying PokitFlyer branding, search button, create button ("Flyern"), and login/profile button with proper navigation logic.

### Steps
1. Create `lib/shared/widgets/app_header.dart`:
   - Build StatelessWidget `AppHeader`
   - Use Container with white background and subtle bottom border
   - Set fixed height (~80px / 60-70 logical pixels)
   - Create horizontal Row layout with proper spacing

2. Implement header layout structure:
   ```dart
   Row(
     mainAxisAlignment: MainAxisAlignment.spaceBetween,
     children: [
       // Left: App branding "PokitFlyer"
       AppLogo(),
       // Right section with 3 buttons
       Row(
         children: [
           SearchButton(),
           CreateFlyerButton(), // "Flyern"
           AuthButton(), // Login or Profile Avatar
         ],
       ),
     ],
   )
   ```

3. Create `lib/shared/widgets/app_logo.dart`:
   - Text widget displaying "PokitFlyer"
   - Use headline font style from theme
   - Add padding for left margin (~16px)
   - Consider using custom font or Icon if design specifies

4. Create `lib/shared/widgets/search_button.dart`:
   - IconButton with search icon (Icons.search)
   - OnPressed: navigate to search (placeholder for now, search will be added in m01-e04)
   - Tooltip: "Search flyers"
   - Size: ~40x40px hit target

5. Create `lib/shared/widgets/create_flyer_button.dart`:
   - Text "Flyern" or Icon (design choice)
   - OnPressed: navigate to `/flyer/create` using go_router
   - Show authentication dialog if user not logged in (placeholder for now)
   - Styled as prominent action button (consider accent color)

6. Create `lib/shared/widgets/auth_button.dart`:
   - StatefulWidget or ConsumerWidget (if using Riverpod for auth state)
   - Display logic:
     - If user NOT logged in: show "Login" button
     - If user logged in: show circular avatar with user's profile image
   - OnPressed logic:
     - Not logged in: navigate to login screen (placeholder route for now)
     - Logged in: navigate to `/profile/:userId` with current user's ID
   - For this task, use mock authentication state (always logged out)

7. Update `lib/features/feed/presentation/screens/feed_screen.dart`:
   - Add AppHeader as persistent element
   - Use Column with AppHeader at top, feed content below
   - Ensure header doesn't scroll with content (fixed position)
   - Structure:
     ```dart
     Scaffold(
       body: Column(
         children: [
           AppHeader(),
           Expanded(
             child: FeedContent(), // placeholder for now
           ),
         ],
       ),
     )
     ```

8. Add safe area handling:
   - Wrap AppHeader in SafeArea to avoid notch overlap
   - Ensure proper padding for iOS status bar

9. Style and polish:
   - Add subtle shadow or border to separate header from content
   - Ensure touch targets are at least 44x44 logical pixels (iOS HIG)
   - Use theme colors consistently
   - Add proper spacing between header elements (~8-16px)

10. Create widget tests in `test/shared/widgets/`:
    - `app_header_test.dart`: Test header renders all child widgets
    - `search_button_test.dart`: Test button renders and tap callback fires
    - `create_flyer_button_test.dart`: Test navigation to create screen
    - `auth_button_test.dart`: Test logged-out state shows "Login", test tap behavior
    - `app_logo_test.dart`: Test logo text displays correctly

11. Create integration test for header navigation:
    - Test tapping search button (placeholder - no navigation yet)
    - Test tapping create button navigates to create screen
    - Test tapping login button (placeholder - no auth yet)
    - Verify header remains visible when feed content scrolls

12. Verify visual design:
    - Run app and inspect header on various iOS device sizes (SE, 14, Pro Max)
    - Check alignment and spacing
    - Verify header stays fixed during scroll (test with long scrollable content)

### Acceptance Criteria
- [ ] Header displays all required elements: logo, search, create, auth button [Test: widget test verifies all widgets present]
- [ ] Header remains fixed at top during content scroll [Test: scroll feed content, header doesn't move]
- [ ] Search button renders with search icon [Test: find widget by icon type]
- [ ] Create button displays "Flyern" and navigates to create screen [Test: tap button, verify route change]
- [ ] Auth button shows "Login" when not authenticated [Test: mock logged-out state]
- [ ] Header respects safe area on iOS devices [Test: run on simulator with notch]
- [ ] All buttons have proper touch targets (≥44x44 logical pixels) [Test: measure widget bounds]
- [ ] Header has subtle visual separation from content [Test: visual inspection]
- [ ] Widget tests pass with >85% coverage [Test: `flutter test --coverage`]
- [ ] No layout overflow or rendering issues [Test: run on small (SE) and large (Pro Max) screens]

### Files to Create/Modify
- `pockitflyer_app/lib/shared/widgets/app_header.dart` - NEW: main header widget
- `pockitflyer_app/lib/shared/widgets/app_logo.dart` - NEW: branding logo widget
- `pockitflyer_app/lib/shared/widgets/search_button.dart` - NEW: search icon button
- `pockitflyer_app/lib/shared/widgets/create_flyer_button.dart` - NEW: create flyer button
- `pockitflyer_app/lib/shared/widgets/auth_button.dart` - NEW: login/profile button
- `pockitflyer_app/lib/features/feed/presentation/screens/feed_screen.dart` - MODIFY: integrate AppHeader
- `pockitflyer_app/test/shared/widgets/app_header_test.dart` - NEW: header widget tests
- `pockitflyer_app/test/shared/widgets/search_button_test.dart` - NEW: search button tests
- `pockitflyer_app/test/shared/widgets/create_flyer_button_test.dart` - NEW: create button tests
- `pockitflyer_app/test/shared/widgets/auth_button_test.dart` - NEW: auth button tests
- `pockitflyer_app/test/shared/widgets/app_logo_test.dart` - NEW: logo widget tests

### Testing Requirements
- **Unit tests**: Not applicable (no business logic)
- **Widget tests**: Each header component in isolation (logo, search, create, auth buttons), full header composition
- **Integration tests**: Header navigation flows (button taps trigger correct routes), header persistence during scroll

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter widget composition best practices
- [ ] No console errors or warnings
- [ ] Header layout is responsive on different iOS screen sizes
- [ ] Comments added for layout calculations and styling decisions
- [ ] Changes committed with reference to task ID (m01-e02-t02)
- [ ] Ready for filter bars and feed content to be added below

## Dependencies
- Requires: m01-e02-t01 (app structure and navigation)
- Blocks: None (other components can be built in parallel)

## Technical Notes
- **Fixed positioning**: Use Column with header at top, Expanded widget for scrollable content below
- **Safe area**: Always wrap in SafeArea to handle iOS notch and status bar
- **Touch targets**: iOS Human Interface Guidelines recommend 44x44 minimum touch targets
- **Navigation**: Use go_router's `context.go()` or `context.push()` for navigation
- **Auth state**: For this task, use hardcoded mock state (always logged out). Real auth will be added in milestone m02
- **Search**: Button is placeholder - search functionality added in m01-e04
- **Theming**: Use theme colors from m01-e02-t01, avoid hardcoded colors
- **Icons**: Use Material Icons (Icons.search, Icons.account_circle, etc.)
- **Spacing**: Use SizedBox or Padding for consistent spacing, prefer theme spacing constants

## References
- Flutter AppBar customization: https://api.flutter.dev/flutter/material/AppBar-class.html
- iOS Human Interface Guidelines (touch targets): https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/
- SafeArea widget: https://api.flutter.dev/flutter/widgets/SafeArea-class.html
- go_router navigation: https://pub.dev/documentation/go_router/latest/
