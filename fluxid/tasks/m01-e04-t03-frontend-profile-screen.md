---
id: m01-e04-t03
epic: m01-e04
title: Create User Profile Screen Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create User Profile Screen Widget

## Objective
Build user profile screen displaying creator information (profile picture, name, bio) and header section.

## Acceptance Criteria
- [ ] ProfileScreen widget accepts user_id as parameter
- [ ] Displays profile picture with circular avatar (or default avatar with initials if missing)
- [ ] Displays username prominently
- [ ] Displays bio text (if available)
- [ ] Loading state while fetching profile data
- [ ] Error state with retry button if profile fetch fails
- [ ] Profile picture loading states (loading, error with fallback to initials)
- [ ] 404 handling if user does not exist (show friendly "User not found" message)
- [ ] AppBar with back button to return to previous screen
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Profile screen renders with all fields populated
- Profile screen with missing profile picture (shows initials)
- Profile screen with missing bio
- Loading state during profile fetch
- Error state and retry behavior
- User not found (404) handling
- Widget tests with mocked API client
- Profile picture loading and fallback states

## Files to Modify/Create
- `pockitflyer_app/lib/screens/profile_screen.dart`
- `pockitflyer_app/lib/widgets/profile_header.dart`
- `pockitflyer_app/lib/services/user_api_client.dart`
- `pockitflyer_app/lib/models/user_profile.dart`
- `pockitflyer_app/test/screens/profile_screen_test.dart`
- `pockitflyer_app/test/widgets/profile_header_test.dart`
- `pockitflyer_app/test/services/user_api_client_test.dart`

## Dependencies
- m01-e04-t01 (User profile API endpoint)

## Notes
- Profile picture fallback: circular avatar with first letter of username or default icon
- Use cached_network_image package for profile picture caching
- Bio text should be truncated with "Read more" if exceeds 3 lines (future enhancement)
- Screen should scroll if bio is very long
- Profile header is visually distinct from flyer feed section below
- Username and profile picture should match what appears on flyer cards
