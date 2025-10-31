---
id: m01-e02-t01
title: Flutter App Structure and Navigation Setup
epic: m01-e02
milestone: m01
status: pending
---

# Task: Flutter App Structure and Navigation Setup

## Context
Part of Core Feed Display and Interaction (m01-e02) in Browse and Discover Local Flyers (m01).

Establishes the foundational Flutter app architecture with navigation, routing, and basic structure. This task sets up the technical foundation that all subsequent UI components will build upon, including go_router for navigation, app theme configuration, and initial route definitions.

## Implementation Guide for LLM Agent

### Objective
Set up Flutter app with navigation system, theme configuration, and folder structure for the feed-based browsing experience.

### Steps
1. Update `pockitflyer_app/pubspec.yaml` with required dependencies:
   - Add `go_router: ^14.0.0` for navigation
   - Add `flutter_riverpod: ^2.5.0` for state management
   - Add `dio: ^5.0.0` for HTTP client
   - Add `freezed_annotation: ^2.4.0` and `json_annotation: ^4.9.0` for models
   - Add dev dependencies: `build_runner`, `freezed`, `json_serializable`
   - Run `flutter pub get` after updating

2. Create folder structure in `pockitflyer_app/lib/`:
   ```
   lib/
   ├── main.dart
   ├── app.dart
   ├── core/
   │   ├── router/
   │   │   └── app_router.dart
   │   ├── theme/
   │   │   └── app_theme.dart
   │   └── constants/
   │       └── app_constants.dart
   ├── features/
   │   └── feed/
   │       ├── presentation/
   │       │   ├── screens/
   │       │   └── widgets/
   │       ├── domain/
   │       │   └── models/
   │       └── data/
   │           └── repositories/
   └── shared/
       └── widgets/
   ```

3. Create `lib/core/theme/app_theme.dart`:
   - Define app color scheme (light mode initially)
   - Set typography styles (headlines, body text, captions)
   - Configure button styles
   - Define card styles for flyer cards
   - Use Material Design 3 with ColorScheme

4. Create `lib/core/router/app_router.dart`:
   - Configure go_router with initial route definitions
   - Define route paths: `/` (home/feed), `/profile/:userId`, `/flyer/create`
   - Set initial location to `/` (feed screen)
   - Add error/404 route handling
   - Configure navigation observers if needed

5. Create `lib/core/constants/app_constants.dart`:
   - Define app name: "PokitFlyer"
   - API base URL (placeholder for now, e.g., `http://localhost:8000/api/v1`)
   - Pagination constants (page size, initial page)
   - Image constants (max images per flyer = 5)
   - Distance units and formatting constants

6. Update `lib/main.dart`:
   - Remove default Flutter demo code
   - Set up `ProviderScope` as root widget
   - Initialize app with minimal configuration
   - Call `runApp(const PokitFlyerApp())`

7. Create `lib/app.dart`:
   - Define `PokitFlyerApp` widget
   - Configure `MaterialApp.router` with go_router
   - Apply app theme
   - Set app title to "PokitFlyer"
   - Configure router delegate and information parser

8. Create placeholder feed screen in `lib/features/feed/presentation/screens/feed_screen.dart`:
   - Basic Scaffold with "Feed Screen" text
   - This will be replaced in subsequent tasks
   - Required for router to have a valid home route

9. Create test structure in `pockitflyer_app/test/`:
   ```
   test/
   ├── core/
   │   ├── router/
   │   │   └── app_router_test.dart
   │   └── theme/
   │       └── app_theme_test.dart
   ├── features/
   │   └── feed/
   │       └── presentation/
   └── widget_test.dart (update or remove default)
   ```

10. Write unit tests for router:
    - Test initial route is `/` (feed)
    - Test navigation to `/profile/:userId` with valid userId
    - Test navigation to `/flyer/create`
    - Test 404/error route handling

11. Write unit tests for theme:
    - Verify color scheme is defined
    - Test primary and secondary colors are set
    - Verify text styles are configured
    - Test theme data can be applied without errors

12. Verify app builds and runs:
    - Run `flutter analyze` to check for issues
    - Run `flutter test` to verify all tests pass
    - Run `flutter run` to verify app launches with placeholder screen

### Acceptance Criteria
- [ ] App builds without errors [Test: `flutter build ios --debug`]
- [ ] All dependencies installed correctly [Test: `flutter pub get` succeeds]
- [ ] Navigation system configured with 3 routes (feed, profile, create) [Test: programmatic navigation in widget test]
- [ ] App theme defines colors, typography, and component styles [Test: theme unit tests pass]
- [ ] Folder structure follows feature-based organization [Test: visual inspection]
- [ ] Placeholder feed screen displays when app launches [Test: run app, see "Feed Screen" text]
- [ ] Router handles invalid routes gracefully [Test: navigate to `/invalid-route`, see error screen]
- [ ] All unit tests pass with >85% coverage [Test: `flutter test --coverage`]
- [ ] No linter warnings [Test: `flutter analyze` shows no issues]

### Files to Create/Modify
- `pockitflyer_app/pubspec.yaml` - MODIFY: add dependencies (go_router, riverpod, dio, freezed, json)
- `pockitflyer_app/lib/main.dart` - MODIFY: remove demo code, set up ProviderScope and app entry
- `pockitflyer_app/lib/app.dart` - NEW: main app widget with MaterialApp.router
- `pockitflyer_app/lib/core/router/app_router.dart` - NEW: go_router configuration
- `pockitflyer_app/lib/core/theme/app_theme.dart` - NEW: app theme definition
- `pockitflyer_app/lib/core/constants/app_constants.dart` - NEW: app-wide constants
- `pockitflyer_app/lib/features/feed/presentation/screens/feed_screen.dart` - NEW: placeholder feed screen
- `pockitflyer_app/test/core/router/app_router_test.dart` - NEW: router unit tests
- `pockitflyer_app/test/core/theme/app_theme_test.dart` - NEW: theme unit tests
- `pockitflyer_app/test/widget_test.dart` - MODIFY: remove default test or update with basic app test

### Testing Requirements
- **Unit tests**: Router configuration (route definitions, navigation), theme configuration (colors, typography, styles)
- **Widget tests**: App widget with router integration, placeholder feed screen renders
- **Integration tests**: Not required for this foundational task

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter/Dart conventions and project style guide
- [ ] No console errors or warnings when running app
- [ ] Folder structure is organized and follows feature-based architecture
- [ ] Comments added for non-obvious configurations (router setup, theme choices)
- [ ] Changes committed with reference to task ID (m01-e02-t01)
- [ ] Ready for dependent tasks (header, feed, cards) to build upon

## Dependencies
- Requires: None (foundation task)
- Blocks: m01-e02-t02 (header), m01-e02-t03 (feed), m01-e02-t04 (cards), m01-e02-t05 (carousel)

## Technical Notes
- **go_router version**: Use 14.x for latest declarative routing features
- **Riverpod**: Use flutter_riverpod (not riverpod) for Flutter integration
- **Theme**: Start with Material Design 3, customize as needed
- **Router strategy**: Use declarative routing with go_router (no imperative Navigator.push)
- **Folder structure**: Feature-based organization (features/feed/, features/profile/) not layer-based (screens/, widgets/)
- **Constants**: Centralize magic numbers and strings in app_constants.dart for maintainability
- **iOS Target**: Ensure iOS deployment target is set correctly in `ios/Podfile` (minimum iOS 12.0)

## References
- go_router documentation: https://pub.dev/packages/go_router
- flutter_riverpod documentation: https://pub.dev/packages/flutter_riverpod
- Material Design 3 in Flutter: https://m3.material.io/
- Flutter navigation patterns: https://docs.flutter.dev/ui/navigation
