---
id: m03-e04-t05
title: Error Handling and Edge Cases Validation (E2E)
epic: m03-e04
milestone: m03
status: pending
---

# Task: Error Handling and Edge Cases Validation (E2E)

## Context
Part of E2E Milestone Validation (m03-e04) in Milestone m03 (Personalized Feed - Favorites & Following).

This task validates error handling, optimistic UI rollback, network failure scenarios, edge cases, and performance under realistic load using REAL backend, REAL database, and REAL network conditions. Tests verify the application degrades gracefully under adverse conditions and maintains data consistency.

**CRITICAL**: This uses the E2E infrastructure from m03-e04-t01. All tests run against real Django backend with NO MOCKS. Network failures and errors are REAL (not simulated).

## Implementation Guide for LLM Agent

### Objective
Create comprehensive E2E tests that validate error handling, optimistic UI rollback on network failures, edge cases (rapid actions, concurrent operations), and performance under realistic load conditions, using real backend services and real network failure simulation.

### Steps

1. **Create E2E test for network failure during favorite action**
   - Create `pockitflyer_app/integration_test/e2e/error_handling/favorite_network_failure_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Optimistic UI rolls back when favorite action fails due to network error',
         tags: ['tdd_red', 'e2e', 'error_handling', 'network'],
         ($) async {
           final test = FavoriteNetworkFailureTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Find first flyer
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;
             final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));

             // Step 3: Verify not favorited initially
             await test.verifyNotFavoritedInDatabase(userId, flyerId);

             final initialIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(initialIcon.icon, Icons.favorite_border, reason: 'Should show unfilled heart initially');

             // Step 4: Enable network failure mode
             await test.networkHelper.enableNetworkFailureMode();

             // Step 5: Tap favorite button
             await $.tap(favoriteButton);
             await $.pump(); // Start optimistic update

             // Step 6: Verify optimistic UI update (heart fills immediately)
             await $.pump(Duration(milliseconds: 100));
             final optimisticIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(optimisticIcon.icon, Icons.favorite, reason: 'Heart should fill optimistically');

             // Step 7: Wait for API request to fail
             await $.pumpAndSettle(timeout: Duration(seconds: 10));

             // Step 8: Verify error message appears
             expect(find.textContaining('Failed to favorite'), findsOneWidget, reason: 'Should show error message');
             expect(find.textContaining('network'), findsOneWidget, reason: 'Error should mention network issue');

             // Step 9: Verify UI rolled back (heart empties again)
             final rolledBackIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(rolledBackIcon.icon, Icons.favorite_border, reason: 'Heart should roll back to unfilled on error');

             // Step 10: Verify database does NOT have favorite record
             await test.verifyNotFavoritedInDatabase(userId, flyerId);

             // Step 11: Restore network
             await test.networkHelper.restoreNormalNetwork();

             // Step 12: Retry favorite action
             await $.tap(favoriteButton);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 13: Verify success this time
             await test.verifyFavoriteInDatabase(userId, flyerId);

             final successIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(successIcon.icon, Icons.favorite, reason: 'Heart should be filled after successful retry');

           } finally {
             // Ensure network restored
             await test.networkHelper.restoreNormalNetwork();
             await test.tearDown();
           }
         },
       );
     }

     class FavoriteNetworkFailureTest extends BaseE2ETest {
       Future<void> verifyNotFavoritedInDatabase(String userId, String flyerId) async {
         final exists = await dbHelper.verifyRecordExists(
           'favorites',
           {'user_id': userId, 'flyer_id': flyerId}
         );
         expect(exists, false, reason: 'Favorite should NOT exist in database');
       }
     }
     ```

2. **Create E2E test for network failure during follow action**
   - Create `pockitflyer_app/integration_test/e2e/error_handling/follow_network_failure_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Optimistic UI rolls back when follow action fails due to network error',
         tags: ['tdd_red', 'e2e', 'error_handling', 'network'],
         ($) async {
           final test = FollowNetworkFailureTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Find first flyer and get creator
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final creatorId = firstFlyerCard.creatorId;
             final followButton = find.byKey(Key('follow_button_$creatorId'));

             // Step 3: Verify not following initially
             await test.verifyNotFollowingInDatabase(userId, creatorId);

             final initialButtonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(initialButtonText.data, 'Follow', reason: 'Should show "Follow" initially');

             // Step 4: Enable network failure mode
             await test.networkHelper.enableNetworkFailureMode();

             // Step 5: Tap follow button
             await $.tap(followButton);
             await $.pump();

             // Step 6: Verify optimistic UI update
             await $.pump(Duration(milliseconds: 100));
             final optimisticButtonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(optimisticButtonText.data, 'Following', reason: 'Should show "Following" optimistically');

             // Step 7: Wait for API request to fail
             await $.pumpAndSettle(timeout: Duration(seconds: 10));

             // Step 8: Verify error message appears
             expect(find.textContaining('Failed to follow'), findsOneWidget, reason: 'Should show error message');

             // Step 9: Verify UI rolled back
             final rolledBackButtonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(rolledBackButtonText.data, 'Follow', reason: 'Should roll back to "Follow" on error');

             // Step 10: Verify database does NOT have following record
             await test.verifyNotFollowingInDatabase(userId, creatorId);

             // Step 11: Restore network and retry
             await test.networkHelper.restoreNormalNetwork();
             await $.tap(followButton);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 12: Verify success
             await test.verifyFollowingInDatabase(userId, creatorId);

           } finally {
             await test.networkHelper.restoreNormalNetwork();
             await test.tearDown();
           }
         },
       );
     }

     class FollowNetworkFailureTest extends BaseE2ETest {
       Future<void> verifyNotFollowingInDatabase(String userId, String creatorId) async {
         final exists = await dbHelper.verifyRecordExists(
           'following',
           {'follower_id': userId, 'followed_id': creatorId}
         );
         expect(exists, false, reason: 'Following relationship should NOT exist in database');
       }
     }
     ```

3. **Create E2E test for rapid consecutive actions (race conditions)**
   - Create `pockitflyer_app/integration_test/e2e/error_handling/rapid_actions_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Rapid favorite/unfavorite actions maintain consistency',
         tags: ['tdd_red', 'e2e', 'error_handling', 'race_conditions'],
         ($) async {
           final test = RapidFavoriteActionsTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Find first flyer
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;
             final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));

             // Step 3: Tap favorite button rapidly 5 times (odd number = final state should be favorited)
             for (int i = 0; i < 5; i++) {
               await $.tap(favoriteButton);
               await $.pump(Duration(milliseconds: 50)); // Very brief pause
             }

             // Step 4: Wait for all requests to settle
             await $.pumpAndSettle(timeout: Duration(seconds: 15));

             // Step 5: Verify final UI state (should be favorited - odd number of taps)
             final finalIcon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(finalIcon.icon, Icons.favorite, reason: 'Final UI state should be favorited');

             // Step 6: Verify database matches UI state
             await test.verifyFavoriteInDatabase(userId, flyerId);

             // Step 7: Verify no duplicate records created
             final favoriteCount = await test.dbHelper.getFavoriteRecordCount(userId, flyerId);
             expect(favoriteCount, equals(1), reason: 'Should have exactly 1 favorite record, not duplicates');

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Rapid follow/unfollow actions maintain consistency',
         tags: ['tdd_red', 'e2e', 'error_handling', 'race_conditions'],
         ($) async {
           final test = RapidFollowActionsTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Find first flyer and get creator
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final creatorId = firstFlyerCard.creatorId;
             final followButton = find.byKey(Key('follow_button_$creatorId'));

             // Step 3: Tap follow button rapidly 4 times (even number = final state should be not following)
             for (int i = 0; i < 4; i++) {
               await $.tap(followButton);
               await $.pump(Duration(milliseconds: 50));
             }

             // Step 4: Wait for all requests to settle
             await $.pumpAndSettle(timeout: Duration(seconds: 15));

             // Step 5: Verify final UI state (should NOT be following - even number of taps)
             final finalButtonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(finalButtonText.data, 'Follow', reason: 'Final UI state should be not following');

             // Step 6: Verify database matches UI state
             await test.verifyNotFollowingInDatabase(userId, creatorId);

             // Step 7: Verify no duplicate records created
             final followingCount = await test.dbHelper.getFollowingRecordCount(userId, creatorId);
             expect(followingCount, equals(0), reason: 'Should have 0 following records');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class RapidFavoriteActionsTest extends BaseE2ETest {}
     class RapidFollowActionsTest extends BaseE2ETest {
       Future<void> verifyNotFollowingInDatabase(String userId, String creatorId) async {
         final exists = await dbHelper.verifyRecordExists(
           'following',
           {'follower_id': userId, 'followed_id': creatorId}
         );
         expect(exists, false, reason: 'Following relationship should NOT exist');
       }
     }
     ```

4. **Create E2E test for backend error responses (4xx, 5xx)**
   - Create `pockitflyer_app/integration_test/e2e/error_handling/backend_error_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Gracefully handles backend 500 errors during favorite',
         tags: ['tdd_red', 'e2e', 'error_handling', 'backend_errors'],
         ($) async {
           final test = Backend500ErrorTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Configure backend to return 500 errors for favorite endpoint
             await test.networkHelper.enableBackendErrorMode(endpoint: '/api/favorites', statusCode: 500);

             // Step 3: Attempt to favorite a flyer
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;
             final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));

             await $.tap(favoriteButton);
             await $.pumpAndSettle(timeout: Duration(seconds: 10));

             // Step 4: Verify user-friendly error message (not raw 500 error)
             expect(find.textContaining('Failed to favorite'), findsOneWidget, reason: 'Should show user-friendly error');
             expect(find.textContaining('500'), findsNothing, reason: 'Should NOT show raw status code to user');
             expect(find.textContaining('try again'), findsOneWidget, reason: 'Should suggest retry');

             // Step 5: Verify UI rolled back
             final icon = $.tester.widget<Icon>(
               find.descendant(of: favoriteButton, matching: find.byType(Icon))
             );
             expect(icon.icon, Icons.favorite_border, reason: 'Should roll back to unfavorited state');

             // Step 6: Verify no database record created
             await test.verifyNotFavoritedInDatabase(userId, flyerId);

             // Step 7: Restore normal backend behavior
             await test.networkHelper.restoreNormalNetwork();

           } finally {
             await test.networkHelper.restoreNormalNetwork();
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Gracefully handles backend 401 unauthorized errors',
         tags: ['tdd_red', 'e2e', 'error_handling', 'backend_errors', 'auth'],
         ($) async {
           final test = Backend401ErrorTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Invalidate auth token (simulate expired token)
             await test.authHelper.invalidateAuthToken();

             // Step 3: Attempt to favorite a flyer
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final flyerId = firstFlyerCard.flyerId;
             final favoriteButton = find.byKey(Key('favorite_button_$flyerId'));

             await $.tap(favoriteButton);
             await $.pumpAndSettle(timeout: Duration(seconds: 10));

             // Step 4: Verify redirected to login or session expired message
             expect(
               find.textContaining('session expired'),
               findsOneWidget,
               reason: 'Should inform user session expired'
             );

             // Step 5: Verify login prompt or automatic redirect to login
             // (Behavior depends on implementation - adjust to match)
             final hasLoginScreen = find.byType(LoginScreen);
             final hasLoginButton = find.text('Login');
             expect(
               hasLoginScreen.evaluate().isNotEmpty || hasLoginButton.evaluate().isNotEmpty,
               true,
               reason: 'Should prompt for re-authentication'
             );

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class Backend500ErrorTest extends BaseE2ETest {
       Future<void> verifyNotFavoritedInDatabase(String userId, String flyerId) async {
         final exists = await dbHelper.verifyRecordExists(
           'favorites',
           {'user_id': userId, 'flyer_id': flyerId}
         );
         expect(exists, false, reason: 'Favorite should NOT exist on error');
       }
     }

     class Backend401ErrorTest extends BaseE2ETest {}
     ```

5. **Create E2E test for performance under load**
   - Create `pockitflyer_app/integration_test/e2e/error_handling/performance_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Feed with 100+ flyers and 50+ favorites performs acceptably',
         tags: ['tdd_red', 'e2e', 'performance'],
         ($) async {
           final test = FeedPerformanceTest();
           await test.setUp();

           try {
             // Step 1: Seed database with large dataset
             await test.dbHelper.seedLargeDataset(
               flyerCount: 100,
               favoriteCount: 50,
               followingCount: 20,
             );

             // Step 2: Login
             await test.authHelper.ensureLoggedInAs('user1');
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Measure initial feed load time
             final loadStartTime = DateTime.now();
             await $.pumpAndSettle(timeout: Duration(seconds: 10));
             final loadEndTime = DateTime.now();

             final loadDuration = loadEndTime.difference(loadStartTime);
             expect(loadDuration.inMilliseconds, lessThan(3000), reason: 'Feed should load within 3 seconds');

             // Step 4: Apply Favorites filter
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final favoritesChip = find.byKey(Key('filter_chip_favorites'));

             final filterStartTime = DateTime.now();
             await $.tap(favoritesChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 10));
             final filterEndTime = DateTime.now();

             final filterDuration = filterEndTime.difference(filterStartTime);
             expect(filterDuration.inMilliseconds, lessThan(1000), reason: 'Filter should apply within 1 second');

             // Step 5: Verify correct number of results
             final filteredFlyerCards = find.byType(FlyerCard);
             final filteredCount = $.tester.widgetList(filteredFlyerCards).length;
             expect(filteredCount, equals(50), reason: 'Should show all 50 favorited flyers');

             // Step 6: Scroll through entire feed (performance during scroll)
             final scrollable = find.byType(Scrollable).first;

             final scrollStartTime = DateTime.now();
             for (int i = 0; i < 10; i++) {
               await $.tester.fling(scrollable, Offset(0, -500), 1000);
               await $.pump(Duration(milliseconds: 100));
             }
             await $.pumpAndSettle();
             final scrollEndTime = DateTime.now();

             final scrollDuration = scrollEndTime.difference(scrollStartTime);
             // Scrolling should be smooth, not janky
             expect(scrollDuration.inMilliseconds, lessThan(5000), reason: 'Scrolling should be smooth');

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Multiple rapid filter changes perform acceptably',
         tags: ['tdd_red', 'e2e', 'performance'],
         ($) async {
           final test = FilterPerformanceTest();
           await test.setUp();

           try {
             // Step 1: Login with existing relationships
             await test.authHelper.ensureLoggedInAs('user1');
             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Rapidly toggle filters
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final filters = ['favorites', 'following', 'events', 'sales'];

             final rapidFilterStartTime = DateTime.now();

             for (int i = 0; i < 10; i++) {
               final filterKey = filters[i % filters.length];
               final chip = find.byKey(Key('filter_chip_$filterKey'));
               await $.tap(chip);
               await $.pump(Duration(milliseconds: 100)); // Brief pause
             }

             await $.pumpAndSettle(timeout: Duration(seconds: 15));
             final rapidFilterEndTime = DateTime.now();

             final rapidFilterDuration = rapidFilterEndTime.difference(rapidFilterStartTime);
             expect(rapidFilterDuration.inMilliseconds, lessThan(10000), reason: 'Rapid filter changes should complete within 10 seconds');

             // Step 3: Verify app is still responsive (no crashes, no freezes)
             expect(find.byType(FeedScreen), findsOneWidget, reason: 'App should still be on feed screen');
             expect(find.byType(FlyerCard), findsWidgets, reason: 'Feed should still show flyers');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FeedPerformanceTest extends BaseE2ETest {}
     class FilterPerformanceTest extends BaseE2ETest {}
     ```

6. **Add network helper methods for error simulation**
   - Update `pockitflyer_app/integration_test/e2e/helpers/network_helper.dart`:
     - Add method: `Future<void> enableBackendErrorMode({required String endpoint, required int statusCode})` - configures backend to return specific error
     - Add method: `Future<void> simulateSlowNetwork({Duration delay})` - adds artificial latency
     - Coordinate with backend E2E test mode to support error injection

7. **Add database helper methods for performance testing**
   - Update `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart`:
     - Add method: `Future<void> seedLargeDataset({required int flyerCount, required int favoriteCount, required int followingCount})` - creates large test dataset
     - Add method: `Future<int> getFavoriteRecordCount(String userId, String flyerId)` - counts favorite records (detect duplicates)
     - Add method: `Future<int> getFollowingRecordCount(String userId, String creatorId)` - counts following records (detect duplicates)

8. **Add auth helper methods for error testing**
   - Update `pockitflyer_app/integration_test/e2e/helpers/auth_helper.dart`:
     - Add method: `Future<void> invalidateAuthToken()` - invalidates current auth token to simulate expiration

9. **Run all error handling E2E tests and mark green when passing**
   - Execute: `flutter test integration_test/e2e/error_handling/ --tags=e2e`
   - Verify all tests pass against real backend with real error conditions
   - Update test tags from `tdd_red` to `tdd_green` in all passing tests
   - Commit with markers updated

### Acceptance Criteria
- [ ] Network failure during favorite causes optimistic UI rollback [Test: favorite_network_failure_test]
- [ ] Network failure during follow causes optimistic UI rollback [Test: follow_network_failure_test]
- [ ] User-friendly error messages shown (not raw HTTP errors) [Test: verify error message text]
- [ ] Rapid favorite/unfavorite maintains consistency (no duplicates, no race conditions) [Test: rapid_actions_test - favorites]
- [ ] Rapid follow/unfollow maintains consistency [Test: rapid_actions_test - following]
- [ ] Backend 500 errors handled gracefully with retry suggestion [Test: backend_error_test - 500]
- [ ] Backend 401 errors prompt re-authentication [Test: backend_error_test - 401]
- [ ] Feed with 100+ flyers loads within 3 seconds [Test: performance_test - feed load]
- [ ] Favorites filter with 50+ favorites applies within 1 second [Test: performance_test - filter performance]
- [ ] Rapid filter changes complete without crashes or freezes [Test: performance_test - rapid filters]
- [ ] All E2E tests pass with real backend and real error conditions [Test: `flutter test integration_test/e2e/error_handling/` exits 0]
- [ ] Tests marked `tdd_green` after passing [Test: inspect test files, verify markers]

### Files to Create/Modify

**Flutter E2E Tests:**
- `pockitflyer_app/integration_test/e2e/error_handling/favorite_network_failure_test.dart` - NEW: Favorite network failure tests
- `pockitflyer_app/integration_test/e2e/error_handling/follow_network_failure_test.dart` - NEW: Follow network failure tests
- `pockitflyer_app/integration_test/e2e/error_handling/rapid_actions_test.dart` - NEW: Race condition and rapid action tests
- `pockitflyer_app/integration_test/e2e/error_handling/backend_error_test.dart` - NEW: Backend error response tests
- `pockitflyer_app/integration_test/e2e/error_handling/performance_test.dart` - NEW: Performance under load tests
- `pockitflyer_app/integration_test/e2e/helpers/network_helper.dart` - MODIFY: Add error simulation methods
- `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart` - MODIFY: Add performance testing and duplicate detection methods
- `pockitflyer_app/integration_test/e2e/helpers/auth_helper.dart` - MODIFY: Add token invalidation method

### Testing Requirements

**E2E Tests (Real Backend - NO MOCKS):**
- All tests run against real Django server with real error simulation
- Network failures are REAL (disconnect from backend, not mocked responses)
- Backend errors are REAL (backend configured to return specific status codes)
- Performance tests use realistic data volumes (100+ flyers, 50+ favorites)
- Tests verify optimistic UI rollback on failures
- Tests verify data consistency after rapid actions
- Tests verify user-friendly error messages
- All tests tagged `e2e` and `error_handling` or `performance`
- Initial marker: `tdd_red`, change to `tdd_green` after verification

### Definition of Done
- [ ] All E2E tests written and pass with real error conditions
- [ ] Optimistic UI rollback verified on network failures
- [ ] Race conditions and rapid actions maintain consistency
- [ ] Backend error responses handled gracefully
- [ ] Performance meets targets under realistic load
- [ ] No console errors or warnings during test execution
- [ ] All tests marked `tdd_green` after passing
- [ ] Changes committed with reference to task ID (m03-e04-t05)

## Dependencies
- Requires: m03-e04-t01 (E2E test environment setup) - Infrastructure must exist
- Requires: m03-e04-t02 (Favorites E2E tests) - Favorites workflow must work
- Requires: m03-e04-t03 (Following E2E tests) - Following workflow must work
- Requires: m03-e04-t04 (Filtering E2E tests) - Filtering must work
- Requires: All M03 feature implementations (E01, E02, E03) - Features must be complete
- Blocks: None (final validation task)

## Technical Notes

**CRITICAL: Real Error Conditions Required**
- Network failures: Use iOS Simulator Network Link Conditioner or backend shutdown
- Backend errors: Configure backend E2E mode to return specific status codes
- Do NOT use mocked error responses - errors must be real

**Optimistic UI Rollback Pattern:**
1. User taps button → UI updates optimistically (immediate feedback)
2. API request sent to backend
3. API fails (network error, 500, etc.)
4. UI rolls back to previous state
5. Error message shown to user
6. User can retry action

**Network Failure Simulation Options:**
- **Option 1**: iOS Simulator → Settings → Developer → Network Link Conditioner → 100% Loss
- **Option 2**: Stop Django backend server during test
- **Option 3**: Backend E2E mode with endpoint-specific failure injection
- Choose the option that best matches your testing infrastructure

**Backend Error Injection:**
- Backend E2E mode should support error injection via test endpoints
- Example: `POST /api/test/inject-error {"endpoint": "/api/favorites", "status": 500}`
- Only enable in E2E_TEST_MODE=true for security

**Race Condition Testing:**
- Rapid taps test the request queue and deduplication logic
- Backend should handle idempotency (multiple identical requests → single result)
- Frontend should queue/debounce rapid actions or use request cancellation
- Verify final state matches database (no duplicates, no lost updates)

**Performance Baseline:**
- Feed load: <3 seconds for 100 flyers
- Filter application: <1 second for 50+ favorites
- Scroll: Smooth (60 FPS) through entire feed
- Rapid filter changes: <10 seconds for 10 rapid toggles
- Adjust baselines if needed based on device performance

**Large Dataset Seeding:**
- Create realistic test data (not minimal fixtures)
- 100 flyers across all categories
- 50 favorites distributed across flyers
- 20 follows distributed across creators
- Use backend seed script or test helper endpoint

**Error Message Quality:**
- ✅ GOOD: "Failed to save favorite. Please check your connection and try again."
- ❌ BAD: "Error 500: Internal Server Error"
- ❌ BAD: "Network request failed: NSURLErrorDomain -1009"
- User-friendly messages increase perceived quality

**401 Unauthorized Handling:**
- Expired tokens should trigger re-authentication flow
- User should be redirected to login screen
- After login, optionally return to original action (deferred action pattern)
- Session expiration should be graceful, not a crash

**Performance Profiling:**
- Use Flutter DevTools performance overlay to verify 60 FPS during tests
- Check for memory leaks during rapid actions
- Verify database queries are optimized (no N+1, proper indexes)

## References
- Flutter error handling best practices: https://docs.flutter.dev/testing/errors
- Optimistic UI patterns: https://www.apollographql.com/docs/react/performance/optimistic-ui/
- iOS Network Link Conditioner: https://nshipster.com/network-link-conditioner/
- Flutter performance profiling: https://docs.flutter.dev/perf/ui-performance
- Race condition testing patterns in codebase (M03 implementation)
