---
id: m04-e01-t01
title: Profile View Page UI and Navigation
epic: m04-e01
milestone: m04
status: pending
---

# Task: Profile View Page UI and Navigation

## Context
Part of Profile Management (m04-e01) in Milestone 4 (m04).

Creates the user profile view page that displays user information and their published flyers. Users access this page by tapping their avatar in the app header. This is a read-only view with an "Edit Profile" button that will navigate to the edit interface (implemented in m04-e01-t02).

## Implementation Guide for LLM Agent

### Objective
Implement profile view page UI in Flutter with navigation from header avatar, displaying user profile information and flyer list.

### Steps

1. Create profile data models
   - Create `pockitflyer_app/lib/models/user_profile.dart`
   - Define UserProfile class with freezed/json_serializable:
     ```dart
     @freezed
     class UserProfile with _$UserProfile {
       const factory UserProfile({
         required String id,
         required String email,
         required String displayName,
         String? profilePictureUrl,
         required bool emailContactAllowed,
         required DateTime createdAt,
         required DateTime updatedAt,
       }) = _UserProfile;

       factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
     }
     ```
   - Create FlyerListItem model for profile flyer list:
     ```dart
     @freezed
     class FlyerListItem with _$FlyerListItem {
       const factory FlyerListItem({
         required String id,
         required String title,
         String? imageUrl,
         required DateTime createdAt,
         required DateTime expiresAt,
         required bool isActive,
       }) = _FlyerListItem;

       factory FlyerListItem.fromJson(Map<String, dynamic> json) => _$FlyerListItemFromJson(json);
     }
     ```
   - Run build_runner to generate code: `flutter pub run build_runner build`

2. Create profile API service
   - Create `pockitflyer_app/lib/services/profile_service.dart`
   - Implement ProfileService class with Dio:
     ```dart
     class ProfileService {
       final Dio _dio;

       ProfileService(this._dio);

       Future<UserProfile> getCurrentUserProfile() async {
         final response = await _dio.get('/api/users/me/profile');
         return UserProfile.fromJson(response.data);
       }

       Future<List<FlyerListItem>> getUserFlyers(String userId) async {
         final response = await _dio.get('/api/users/$userId/flyers');
         return (response.data as List)
           .map((item) => FlyerListItem.fromJson(item))
           .toList();
       }
     }
     ```
   - Add error handling (network errors, 401 unauthorized, 404 not found)
   - Include authorization header from auth state

3. Create profile state provider
   - Create `pockitflyer_app/lib/providers/profile_provider.dart`
   - Define AsyncNotifierProvider for profile state:
     ```dart
     @riverpod
     class ProfileNotifier extends _$ProfileNotifier {
       @override
       Future<UserProfile> build() async {
         final profileService = ref.read(profileServiceProvider);
         return await profileService.getCurrentUserProfile();
       }

       Future<void> refresh() async {
         state = const AsyncValue.loading();
         state = await AsyncValue.guard(() async {
           final profileService = ref.read(profileServiceProvider);
           return await profileService.getCurrentUserProfile();
         });
       }
     }

     @riverpod
     class UserFlyersNotifier extends _$UserFlyersNotifier {
       @override
       Future<List<FlyerListItem>> build(String userId) async {
         final profileService = ref.read(profileServiceProvider);
         return await profileService.getUserFlyers(userId);
       }
     }
     ```

4. Create profile view screen widget
   - Create `pockitflyer_app/lib/screens/profile_screen.dart`
   - Implement ProfileScreen widget:
     - Use Scaffold with AppBar (title: "Profile", back button)
     - Watch profileProvider and userFlyersProvider
     - Handle AsyncValue states (loading, error, data)
     - Loading state: Show shimmer/skeleton loaders
     - Error state: Show error message with retry button
     - Data state: Display profile information
   - Profile header section:
     - Circular profile picture (150x150) with placeholder if null
     - Display name (Text, style: headline5, bold)
     - Email (Text, style: subtitle2, gray)
     - "Edit Profile" button (ElevatedButton, navigate to edit screen)
   - Flyers list section:
     - SectionHeader: "My Flyers" with count badge
     - ListView.builder for flyer items
     - Empty state: "No flyers yet" with icon
     - Each flyer card shows:
       - Thumbnail image (80x80) or placeholder
       - Title (Text, style: subtitle1)
       - Created date (Text, style: caption)
       - Status badge: "Active" (green) or "Expired" (gray)
     - Tap handler: navigate to flyer detail screen

5. Add navigation route
   - Modify `pockitflyer_app/lib/main.dart` (or router configuration file)
   - Add profile route to GoRouter:
     ```dart
     GoRoute(
       path: '/profile',
       name: 'profile',
       builder: (context, state) => const ProfileScreen(),
     ),
     ```

6. Update header avatar to navigate to profile
   - Locate existing header/app bar widget (search for AppBar usage)
   - Find avatar/user icon widget in header
   - Add onTap handler to avatar:
     ```dart
     GestureDetector(
       onTap: () {
         // Check if user is authenticated
         final authState = ref.read(authStateProvider);
         if (authState.isAuthenticated) {
           context.go('/profile');
         } else {
           // Show login prompt or navigate to login
           context.go('/login');
         }
       },
       child: CircleAvatar(...),
     )
     ```
   - Handle unauthenticated state gracefully

7. Create widget tests
   - Create `pockitflyer_app/test/screens/profile_screen_test.dart`
   - Test ProfileScreen widget:
     - Renders loading state correctly (shimmer/skeleton visible)
     - Renders error state with retry button
     - Displays profile information when data loaded
     - Shows profile picture or placeholder
     - Displays correct flyer count
     - Renders flyer list correctly (active/expired badges)
     - Shows empty state when no flyers
     - "Edit Profile" button navigates to edit screen
     - Handles missing profile picture gracefully
   - Mock profileProvider and userFlyersProvider with ProviderScope override

8. Create unit tests for models and services
   - Create `pockitflyer_app/test/models/user_profile_test.dart`
   - Test UserProfile.fromJson deserialization
   - Test FlyerListItem.fromJson deserialization
   - Create `pockitflyer_app/test/services/profile_service_test.dart`
   - Test ProfileService.getCurrentUserProfile (success, 401, 404, network error)
   - Test ProfileService.getUserFlyers (success, empty list, errors)
   - Mock Dio using mockito or similar

### Acceptance Criteria
- [ ] Tapping header avatar navigates to profile screen [Test: authenticated user tap, unauthenticated user tap shows login prompt]
- [ ] Profile screen displays user information correctly [Test: profile picture (present/missing), display name, email]
- [ ] Profile screen shows list of user's flyers [Test: multiple flyers with active/expired status, empty state when no flyers]
- [ ] Active and expired flyers are visually distinguished [Test: badge colors, status labels]
- [ ] Loading states display during data fetch [Test: shimmer/skeleton visible before data loads]
- [ ] Error states show with retry option [Test: network error, 404 error, retry button refetches data]
- [ ] "Edit Profile" button is visible and tappable [Test: button renders, tap handler defined]
- [ ] All widget tests pass with >85% coverage [Test: run `flutter test`]
- [ ] All unit tests pass [Test: model deserialization, service methods, error handling]

### Files to Create/Modify
- `pockitflyer_app/lib/models/user_profile.dart` - NEW: UserProfile and FlyerListItem models
- `pockitflyer_app/lib/services/profile_service.dart` - NEW: ProfileService for API calls
- `pockitflyer_app/lib/providers/profile_provider.dart` - NEW: Profile state providers
- `pockitflyer_app/lib/screens/profile_screen.dart` - NEW: Profile view screen widget
- `pockitflyer_app/lib/main.dart` - MODIFY: Add profile route to GoRouter
- `pockitflyer_app/lib/widgets/app_header.dart` (or equivalent) - MODIFY: Add navigation to avatar tap
- `pockitflyer_app/test/screens/profile_screen_test.dart` - NEW: Widget tests
- `pockitflyer_app/test/models/user_profile_test.dart` - NEW: Model tests
- `pockitflyer_app/test/services/profile_service_test.dart` - NEW: Service tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - UserProfile.fromJson with valid/invalid data
  - FlyerListItem.fromJson with valid/invalid data
  - ProfileService.getCurrentUserProfile (success, 401, 404, network error)
  - ProfileService.getUserFlyers (success, empty list, errors)

- **Widget tests**:
  - ProfileScreen loading state (shimmer visible)
  - ProfileScreen error state (error message, retry button)
  - ProfileScreen data state (profile info, flyer list)
  - Empty flyer list state
  - Profile picture rendering (with/without image)
  - Active/expired flyer badges
  - "Edit Profile" button tap

- **Integration tests**:
  - Full profile screen with mocked API responses
  - Navigation from header avatar to profile screen
  - Refresh flow (pull-to-refresh if implemented)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Flutter/Dart style guide)
- [ ] No console errors or warnings
- [ ] Documentation/comments added where needed (complex logic only)
- [ ] Changes committed with reference to task ID (m04-e01-t01)
- [ ] Ready for dependent tasks to use (m04-e01-t02 needs profile screen for navigation)

## Dependencies
- Requires: m02-e01 (authentication system - auth state provider, JWT tokens)
- Requires: m03 (flyer publishing - user has flyers to display)
- Blocks: m04-e01-t02 (edit interface needs this view for navigation back)

## Technical Notes
- **Authentication**: Profile endpoint requires JWT token in Authorization header
- **Image URLs**: Backend returns full URLs for profile pictures and flyer thumbnails
- **Date formatting**: Use intl package for date display (e.g., "Created: Jan 15, 2025")
- **Placeholders**: Use asset placeholder image or colored circle with initials for missing profile pictures
- **Flyer status**: Determine active/expired by comparing `expiresAt` with current date
- **Error handling**: Network errors should be user-friendly ("Unable to load profile. Check your connection.")
- **State management**: Use riverpod's AsyncValue pattern for loading/error/data states
- **Pull-to-refresh**: Optional - consider adding RefreshIndicator for manual refresh
- **Avatar in header**: Ensure avatar shows user's profile picture (if available) or placeholder

## References
- Flutter riverpod documentation: https://riverpod.dev/
- GoRouter navigation: https://pub.dev/packages/go_router
- Freezed models: https://pub.dev/packages/freezed
- AsyncValue pattern: https://riverpod.dev/docs/concepts/async_value
