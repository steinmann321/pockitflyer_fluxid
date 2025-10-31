---
id: m03-e04-t02
title: Favorite/Unfavorite User Journey Validation (E2E)
epic: m03-e04
milestone: m03
status: pending
---

# Task: Favorite/Unfavorite User Journey Validation (E2E)

## Context
Part of E2E Milestone Validation (m03-e04) in Milestone m03 (Personalized Feed - Favorites & Following).

This task validates the complete favorite/unfavorite user journey end-to-end with REAL backend, REAL database, and REAL authentication. Tests verify that authenticated users can favorite flyers, see visual feedback, persist state across app restarts, and unfavorite flyers - all with actual database verification.

**CRITICAL**: This uses the E2E infrastructure from m03-e04-t01. All tests run against real Django backend with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create comprehensive E2E tests that validate the complete favorite/unfavorite user journey from user action through UI updates to database persistence, using real backend services and database verification.

### Steps

1. **Create E2E test for authenticated favorite workflow**
   - Create `pockitflyer_app/integration_test/e2e/favorites/favorite_workflow_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';
     import '../config/e2e_test_config.dart';

     void main() {
       patrolTest(
         'Authenticated user can favorite a flyer with full persistence',
         tags: ['tdd_red', 'e2e', 'favorites'],
         ($) async {
           final test = FavoriteWorkflowTest();
           await test.setUp();

           try {
             // Step 1: Login as test user3 (clean slate)
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             // Step 2: Launch app and navigate to feed
             await $.pumpWidgetAndSettle(MyApp()); // Your app entry point

             // Step 3: Find first flyer in feed (not already favorited)
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;

             // Step 4: Verify flyer is NOT favorited initially
             await test.verifyNotFavoritedInDatabase(userId, flyerId);

             // Step 5: Find favorite button (should show unfilled heart icon)
             final favoriteButton = find.descendant(
               of: find.byType(FlyerCard).first,
               matching: find.byKey(Key('favorite_button_$flyerId'))
             );
             expect(favoriteButton, findsOneWidget, reason: 'Favorite button should exist');

             final favoriteIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(favoriteIcon.icon, Icons.favorite_border, reason: 'Should show unfilled heart');

             // Step 6: Tap favorite button
             await $.tap(favoriteButton);
             await $.pump(); // Start optimistic update

             // Step 7: Verify optimistic UI update (heart fills immediately)
             await $.pump(Duration(milliseconds: 100));
             final updatedIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(updatedIcon.icon, Icons.favorite, reason: 'Heart should fill optimistically');

             // Step 8: Wait for API request to complete
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 9: Verify database has favorite record
             await test.verifyFavoriteInDatabase(userId, flyerId);

             // Step 10: Verify UI still shows favorited state
             final finalIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(finalIcon.icon, Icons.favorite, reason: 'Heart should remain filled');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FavoriteWorkflowTest extends BaseE2ETest {
       Future<void> verifyNotFavoritedInDatabase(String userId, String flyerId) async {
         final exists = await dbHelper.verifyRecordExists(
           'favorites',
           {'user_id': userId, 'flyer_id': flyerId}
         );
         expect(exists, false, reason: 'Favorite should NOT exist in database initially');
       }
     }
     ```

2. **Create E2E test for unfavorite workflow**
   - Add to same file `pockitflyer_app/integration_test/e2e/favorites/favorite_workflow_test.dart`:
     ```dart
     patrolTest(
       'Authenticated user can unfavorite a flyer with full persistence',
       tags: ['tdd_red', 'e2e', 'favorites'],
       ($) async {
         final test = UnfavoriteWorkflowTest();
         await test.setUp();

         try {
           // Step 1: Login as test user1 (has existing favorites from seed data)
           await test.authHelper.ensureLoggedInAs('user1');
           final userId = await test.authHelper.getCurrentUserId();

           // Step 2: Launch app and navigate to feed
           await $.pumpWidgetAndSettle(MyApp());

           // Step 3: Find a flyer that is already favorited
           final favoritedFlyerId = await test.dbHelper.getFirstFavoritedFlyerForUser(userId);
           expect(favoritedFlyerId, isNotNull, reason: 'User1 should have favorited flyers from seed data');

           // Step 4: Verify flyer IS favorited initially in database
           await test.verifyFavoriteInDatabase(userId, favoritedFlyerId!);

           // Step 5: Find the favorited flyer card in feed
           final favoritedFlyerCard = find.byKey(Key('flyer_card_$favoritedFlyerId'));
           await $.scrollUntilVisible(finder: favoritedFlyerCard);

           // Step 6: Find favorite button (should show filled heart icon)
           final favoriteButton = find.descendant(
             of: favoritedFlyerCard,
             matching: find.byKey(Key('favorite_button_$favoritedFlyerId'))
           );

           final favoriteIcon = $.tester.widget<Icon>(
             find.descendant(of: favoriteButton, matching: find.byType(Icon))
           );
           expect(favoriteIcon.icon, Icons.favorite, reason: 'Should show filled heart');

           // Step 7: Tap favorite button to unfavorite
           await $.tap(favoriteButton);
           await $.pump(); // Start optimistic update

           // Step 8: Verify optimistic UI update (heart empties immediately)
           await $.pump(Duration(milliseconds: 100));
           final updatedIcon = $.tester.widget<Icon>(
             find.descendant(of: favoriteButton, matching: find.byType(Icon))
           );
           expect(updatedIcon.icon, Icons.favorite_border, reason: 'Heart should empty optimistically');

           // Step 9: Wait for API request to complete
           await $.pumpAndSettle(timeout: Duration(seconds: 5));

           // Step 10: Verify database has removed favorite record
           await test.verifyNotFavoritedInDatabase(userId, favoritedFlyerId);

           // Step 11: Verify UI still shows unfavorited state
           final finalIcon = $.tester.widget<Icon>(
             find.descendant(of: favoriteButton, matching: find.byType(Icon))
           );
           expect(finalIcon.icon, Icons.favorite_border, reason: 'Heart should remain empty');

         } finally {
           await test.tearDown();
         }
       },
     );

     class UnfavoriteWorkflowTest extends BaseE2ETest {
       Future<void> verifyNotFavoritedInDatabase(String userId, String flyerId) async {
         final exists = await dbHelper.verifyRecordExists(
           'favorites',
           {'user_id': userId, 'flyer_id': flyerId}
         );
         expect(exists, false, reason: 'Favorite should NOT exist in database after unfavorite');
       }
     }
     ```

3. **Create E2E test for favorite state persistence across app restarts**
   - Add to same file:
     ```dart
     patrolTest(
       'Favorite state persists across app restarts',
       tags: ['tdd_red', 'e2e', 'favorites', 'persistence'],
       ($) async {
         final test = FavoritePersistenceTest();
         await test.setUp();

         try {
           // Step 1: Login and favorite a flyer
           await test.authHelper.ensureLoggedInAs('user3');
           final userId = await test.authHelper.getCurrentUserId();

           await $.pumpWidgetAndSettle(MyApp());

           final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
           final flyerId = firstFlyerCard.flyerId;

           final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));
           await $.tap(favoriteButton);
           await $.pumpAndSettle(timeout: Duration(seconds: 5));

           // Verify favorited in database
           await test.verifyFavoriteInDatabase(userId, flyerId);

           // Step 2: Close app (simulate app termination)
           await $.tester.pumpWidget(Container()); // Remove app from widget tree
           await $.pump(Duration(seconds: 1));

           // Step 3: Reopen app (re-launch)
           await $.pumpWidgetAndSettle(MyApp());

           // User should still be logged in (token persists in storage)
           // Wait for app to load and fetch flyers
           await $.pump(Duration(seconds: 2));
           await $.pumpAndSettle();

           // Step 4: Find the same flyer card
           final reloadedFlyerCard = find.byKey(Key('flyer_card_$flyerId'));

           // Step 5: Verify favorite button shows filled heart (state persisted)
           final favoriteButtonAfterRestart = find.descendant(
             of: reloadedFlyerCard,
             matching: find.byKey(Key('favorite_button_$flyerId'))
           );

           final iconAfterRestart = $.tester.widget<Icon>(
             find.descendant(of: favoriteButtonAfterRestart, matching: find.byType(Icon))
           );
           expect(iconAfterRestart.icon, Icons.favorite, reason: 'Favorite state should persist after app restart');

           // Step 6: Verify still in database
           await test.verifyFavoriteInDatabase(userId, flyerId);

         } finally {
           await test.tearDown();
         }
       },
     );

     class FavoritePersistenceTest extends BaseE2ETest {}
     ```

4. **Create E2E test for anonymous user auth gate for favorites**
   - Create `pockitflyer_app/integration_test/e2e/favorites/favorite_auth_gate_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';
     import '../config/e2e_test_config.dart';

     void main() {
       patrolTest(
         'Anonymous user sees login prompt when tapping favorite button',
         tags: ['tdd_red', 'e2e', 'favorites', 'auth_gate'],
         ($) async {
           final test = FavoriteAuthGateTest();
           await test.setUp();

           try {
             // Step 1: Ensure user is logged out (anonymous)
             await test.authHelper.logoutAndClearState();

             // Step 2: Launch app as anonymous user
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Browse feed (should work for anonymous users)
             expect(find.byType(FlyerCard), findsWidgets, reason: 'Anonymous users can browse feed');

             // Step 4: Find first flyer and favorite button
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;
             final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));

             // Step 5: Tap favorite button
             await $.tap(favoriteButton);
             await $.pumpAndSettle();

             // Step 6: Verify login prompt appears
             expect(find.text('Login Required'), findsOneWidget, reason: 'Should show login prompt title');
             expect(
               find.textContaining('favorite flyers'),
               findsOneWidget,
               reason: 'Should explain why login is needed'
             );

             // Step 7: Verify action buttons in prompt
             expect(find.text('Login'), findsOneWidget, reason: 'Should have Login button');
             expect(find.text('Cancel'), findsOneWidget, reason: 'Should have Cancel button');

             // Step 8: Tap Cancel and verify dialog dismisses
             await $.tap(find.text('Cancel'));
             await $.pumpAndSettle();
             expect(find.text('Login Required'), findsNothing, reason: 'Dialog should dismiss');

             // Step 9: Verify no favorite was created (anonymous user can't favorite)
             // No database check needed - anonymous users don't have userId

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Anonymous user can complete login flow from favorite auth gate',
         tags: ['tdd_red', 'e2e', 'favorites', 'auth_gate', 'login_flow'],
         ($) async {
           final test = FavoriteAuthGateLoginTest();
           await test.setUp();

           try {
             // Step 1: Ensure user is logged out
             await test.authHelper.logoutAndClearState();

             // Step 2: Launch app and navigate to feed
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Tap favorite button to trigger auth gate
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;
             final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));

             await $.tap(favoriteButton);
             await $.pumpAndSettle();

             // Step 4: Tap Login button in auth gate dialog
             await $.tap(find.text('Login'));
             await $.pumpAndSettle();

             // Step 5: Verify redirected to login screen
             expect(find.byType(LoginScreen), findsOneWidget, reason: 'Should navigate to login screen');

             // Step 6: Complete login flow
             await $.enterText(
               find.byKey(Key('login_email_field')),
               E2ETestConfig.testUsers['user3']!['email']!
             );
             await $.enterText(
               find.byKey(Key('login_password_field')),
               E2ETestConfig.testUsers['user3']!['password']!
             );
             await $.tap(find.byKey(Key('login_submit_button')));
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 7: Verify returned to feed after successful login
             expect(find.byType(FeedScreen), findsOneWidget, reason: 'Should return to feed after login');

             // Step 8: Verify favorite action completed automatically
             // (App should remember user wanted to favorite this flyer)
             final userId = await test.authHelper.getCurrentUserId();

             // Give app time to complete deferred favorite action
             await $.pump(Duration(seconds: 2));
             await $.pumpAndSettle();

             // Step 9: Verify favorite was created after login
             await test.verifyFavoriteInDatabase(userId, flyerId);

             // Step 10: Verify UI shows favorited state
             final favoriteIcon = $.tester.widget<Icon>(
               find.descendant(
                 of: find.byKey(Key('favorite_button_$flyerId')),
                 matching: find.byType(Icon)
               )
             );
             expect(favoriteIcon.icon, Icons.favorite, reason: 'Heart should be filled after deferred favorite');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FavoriteAuthGateTest extends BaseE2ETest {}
     class FavoriteAuthGateLoginTest extends BaseE2ETest {}
     ```

5. **Create E2E test for multiple favorites workflow**
   - Create `pockitflyer_app/integration_test/e2e/favorites/multiple_favorites_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'User can favorite multiple flyers in sequence',
         tags: ['tdd_red', 'e2e', 'favorites'],
         ($) async {
           final test = MultipleFavoritesTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Favorite first 5 flyers in feed
             final flyerCards = find.byType(FlyerCard);
             final favoritedFlyerIds = <String>[];

             for (int i = 0; i < 5; i++) {
               final flyerCard = $.tester.widget(flyerCards.at(i));
               final flyerId = flyerCard.flyerId;
               favoritedFlyerIds.add(flyerId);

               final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));
               await $.scrollUntilVisible(finder: favoriteButton);
               await $.tap(favoriteButton);
               await $.pump(Duration(milliseconds: 500)); // Brief pause between favorites
             }

             // Step 3: Wait for all API requests to complete
             await $.pumpAndSettle(timeout: Duration(seconds: 10));

             // Step 4: Verify all 5 favorites exist in database
             for (final flyerId in favoritedFlyerIds) {
               await test.verifyFavoriteInDatabase(userId, flyerId);
             }

             // Step 5: Verify all 5 flyer cards show favorited state
             for (final flyerId in favoritedFlyerIds) {
               final favoriteIcon = $.tester.widget<Icon>(
                 find.descendant(
                   of: find.byKey(Key('favorite_button_$flyerId')),
                   matching: find.byType(Icon)
                 )
               );
               expect(favoriteIcon.icon, Icons.favorite, reason: 'Flyer $flyerId should show filled heart');
             }

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class MultipleFavoritesTest extends BaseE2ETest {}
     ```

6. **Add database helper methods for favorite verification**
   - Update `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart`:
     - Add method: `Future<String?> getFirstFavoritedFlyerForUser(String userId)` - returns flyerId of first favorite
     - Add method: `Future<List<String>> getAllFavoritedFlyerIdsForUser(String userId)` - returns all favorited flyer IDs
     - Add method: `Future<int> getFavoriteCountForUser(String userId)` - returns count of favorites

7. **Update auth helper to get current user ID**
   - Update `pockitflyer_app/integration_test/e2e/helpers/auth_helper.dart`:
     - Add method: `Future<String> getCurrentUserId()` - extracts userId from JWT token or API call
     - Add method: `Future<bool> isLoggedIn()` - checks if user has valid token

8. **Run all favorite E2E tests and mark green when passing**
   - Execute: `flutter test integration_test/e2e/favorites/ --tags=e2e`
   - Verify all tests pass against real backend
   - Update test tags from `tdd_red` to `tdd_green` in all passing tests
   - Commit with markers updated

### Acceptance Criteria
- [ ] Authenticated user can favorite a flyer with database persistence [Test: favorite_workflow_test - favorite path]
- [ ] Authenticated user can unfavorite a flyer with database removal [Test: favorite_workflow_test - unfavorite path]
- [ ] Optimistic UI updates occur immediately before API completes [Test: verify icon changes before pumpAndSettle]
- [ ] Favorite state persists across app restarts [Test: persistence test closes/reopens app, verifies state]
- [ ] Anonymous users see login prompt when tapping favorite [Test: auth_gate_test - anonymous tap favorite]
- [ ] Anonymous users can complete login from auth gate and favorite action completes [Test: auth_gate_test - login flow]
- [ ] Multiple flyers can be favorited in sequence [Test: multiple_favorites_test - 5 sequential favorites]
- [ ] Database verification confirms all favorite operations [Test: all tests use verifyFavoriteInDatabase]
- [ ] All E2E tests pass with real backend [Test: `flutter test integration_test/e2e/favorites/` exits 0]
- [ ] Tests marked `tdd_green` after passing [Test: inspect test files, verify markers]

### Files to Create/Modify

**Flutter E2E Tests:**
- `pockitflyer_app/integration_test/e2e/favorites/favorite_workflow_test.dart` - NEW: Favorite/unfavorite/persistence tests
- `pockitflyer_app/integration_test/e2e/favorites/favorite_auth_gate_test.dart` - NEW: Anonymous user auth gate tests
- `pockitflyer_app/integration_test/e2e/favorites/multiple_favorites_test.dart` - NEW: Multiple favorites workflow test
- `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart` - MODIFY: Add favorite-specific query methods
- `pockitflyer_app/integration_test/e2e/helpers/auth_helper.dart` - MODIFY: Add getCurrentUserId and isLoggedIn methods

### Testing Requirements

**E2E Tests (Real Backend - NO MOCKS):**
- All tests run against real Django server started via m03-e04-t01 scripts
- All tests verify database state using real SQL queries
- All tests use real JWT authentication tokens
- Tests cover happy path (favorite/unfavorite) and auth gate scenarios
- Tests verify optimistic UI updates and eventual consistency
- Tests verify persistence across app restarts
- All tests tagged `e2e` and `favorites`
- Initial marker: `tdd_red`, change to `tdd_green` after verification

### Definition of Done
- [ ] All E2E tests written and pass against real backend
- [ ] Database verification confirms all favorite operations
- [ ] Optimistic UI updates work correctly
- [ ] Auth gate redirects anonymous users to login
- [ ] Persistence across app restarts works
- [ ] No console errors or warnings during test execution
- [ ] All tests marked `tdd_green` after passing
- [ ] Changes committed with reference to task ID (m03-e04-t02)

## Dependencies
- Requires: m03-e04-t01 (E2E test environment setup) - Infrastructure must exist
- Requires: M03-E01 (Flyer favorites) - Feature implementation must be complete
- Requires: M02-E01 (Authentication) - Login flow must work
- Blocks: m03-e04-t05 (Error handling) - Some error tests build on favorite scenarios

## Technical Notes

**CRITICAL: Real Backend Required**
- Backend server must be running: `cd pockitflyer_backend && ./scripts/run_e2e_server.sh`
- Tests will fail if backend is not accessible on http://localhost:8001
- Database must have seed data (user1 with favorites, user3 clean slate)

**Optimistic UI Testing Strategy:**
- Tests verify UI updates BEFORE `pumpAndSettle()` (optimistic update)
- Tests verify UI still correct AFTER `pumpAndSettle()` (server confirmation)
- This validates the optimistic update pattern works correctly

**Database Verification Pattern:**
```dart
// Always verify both UI state AND database state
await test.verifyFavoriteInDatabase(userId, flyerId); // Database
expect(icon.icon, Icons.favorite); // UI
```

**App Restart Simulation:**
- Use `$.tester.pumpWidget(Container())` to remove app from widget tree
- Use `$.pumpWidgetAndSettle(MyApp())` to re-launch app
- This simulates full app termination and restart
- Verify auth tokens persist in storage (secure storage or shared preferences)

**Auth Gate Deferred Action:**
- When anonymous user taps favorite → login prompt appears
- User completes login
- App should "remember" the original favorite action and complete it after login
- This is a UX enhancement - verify implementation handles this gracefully
- If not implemented, document as known limitation

**Widget Keys for Testing:**
- Ensure all flyer cards have unique keys: `Key('flyer_card_$flyerId')`
- Ensure all favorite buttons have unique keys: `Key('favorite_button_$flyerId')`
- This allows tests to target specific flyers reliably

**Test Execution Performance:**
- E2E tests are slower than unit/integration tests (real network, real database)
- Each test should complete in <30 seconds
- If tests are too slow, investigate:
  - Backend performance (database queries, API response time)
  - Network latency (use localhost, not remote server)
  - Unnecessary waits in test code (optimize pumpAndSettle usage)

## References
- Patrol testing patterns: https://patrol.leancode.co/
- Flutter integration test best practices: https://docs.flutter.dev/testing/integration-tests
- Optimistic UI patterns in the codebase (M03-E01 implementation)
- Auth gate implementation (M03-E01 task files)
