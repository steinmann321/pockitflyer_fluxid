---
id: m03-e04-t03
title: Follow/Unfollow User Journey Validation (E2E)
epic: m03-e04
milestone: m03
status: pending
---

# Task: Follow/Unfollow User Journey Validation (E2E)

## Context
Part of E2E Milestone Validation (m03-e04) in Milestone m03 (Personalized Feed - Favorites & Following).

This task validates the complete follow/unfollow creator user journey end-to-end with REAL backend, REAL database, and REAL authentication. Tests verify that authenticated users can follow creators, see visual feedback, persist state across app restarts, and unfollow creators - all with actual database verification.

**CRITICAL**: This uses the E2E infrastructure from m03-e04-t01. All tests run against real Django backend with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create comprehensive E2E tests that validate the complete follow/unfollow creator journey from user action through UI updates to database persistence, using real backend services and database verification.

### Steps

1. **Create E2E test for authenticated follow workflow**
   - Create `pockitflyer_app/integration_test/e2e/following/follow_workflow_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';
     import '../config/e2e_test_config.dart';

     void main() {
       patrolTest(
         'Authenticated user can follow a creator with full persistence',
         tags: ['tdd_red', 'e2e', 'following'],
         ($) async {
           final test = FollowWorkflowTest();
           await test.setUp();

           try {
             // Step 1: Login as test user3 (clean slate)
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             // Step 2: Launch app and navigate to feed
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Find first flyer in feed and get creator info
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final creatorId = firstFlyerCard.creatorId;

             // Step 4: Verify NOT following creator initially
             await test.verifyNotFollowingInDatabase(userId, creatorId);

             // Step 5: Find follow button (should show "Follow" text or outline icon)
             final followButton = find.descendant(
               of: find.byType(FlyerCard).first,
               matching: find.byKey(Key('follow_button_$creatorId'))
             );
             expect(followButton, findsOneWidget, reason: 'Follow button should exist');

             // Verify button shows "Follow" state
             final buttonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(buttonText.data, 'Follow', reason: 'Button should show "Follow" initially');

             // Step 6: Tap follow button
             await $.tap(followButton);
             await $.pump(); // Start optimistic update

             // Step 7: Verify optimistic UI update (button changes to "Following" immediately)
             await $.pump(Duration(milliseconds: 100));
             final updatedButtonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(updatedButtonText.data, 'Following', reason: 'Button should change optimistically');

             // Step 8: Wait for API request to complete
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 9: Verify database has following record
             await test.verifyFollowingInDatabase(userId, creatorId);

             // Step 10: Verify UI still shows following state
             final finalButtonText = $.tester.widget<Text>(
               find.descendant(of: followButton, matching: find.byType(Text))
             );
             expect(finalButtonText.data, 'Following', reason: 'Button should remain "Following"');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FollowWorkflowTest extends BaseE2ETest {
       Future<void> verifyNotFollowingInDatabase(String followerId, String followedId) async {
         final exists = await dbHelper.verifyRecordExists(
           'following',
           {'follower_id': followerId, 'followed_id': followedId}
         );
         expect(exists, false, reason: 'Following relationship should NOT exist in database initially');
       }
     }
     ```

2. **Create E2E test for unfollow workflow**
   - Add to same file `pockitflyer_app/integration_test/e2e/following/follow_workflow_test.dart`:
     ```dart
     patrolTest(
       'Authenticated user can unfollow a creator with full persistence',
       tags: ['tdd_red', 'e2e', 'following'],
       ($) async {
         final test = UnfollowWorkflowTest();
         await test.setUp();

         try {
           // Step 1: Login as test user1 (has existing follows from seed data)
           await test.authHelper.ensureLoggedInAs('user1');
           final userId = await test.authHelper.getCurrentUserId();

           // Step 2: Launch app and navigate to feed
           await $.pumpWidgetAndSettle(MyApp());

           // Step 3: Find a creator that is already followed
           final followedCreatorId = await test.dbHelper.getFirstFollowedCreatorForUser(userId);
           expect(followedCreatorId, isNotNull, reason: 'User1 should have followed creators from seed data');

           // Step 4: Verify following relationship exists in database
           await test.verifyFollowingInDatabase(userId, followedCreatorId!);

           // Step 5: Find a flyer from the followed creator
           final followedCreatorFlyer = find.byKey(Key('flyer_creator_$followedCreatorId')).first;
           await $.scrollUntilVisible(finder: followedCreatorFlyer);

           // Step 6: Find follow button (should show "Following" state)
           final followButton = find.descendant(
               of: followedCreatorFlyer,
               matching: find.byKey(Key('follow_button_$followedCreatorId'))
           );

           final buttonText = $.tester.widget<Text>(
             find.descendant(of: followButton, matching: find.byType(Text))
           );
           expect(buttonText.data, 'Following', reason: 'Button should show "Following"');

           // Step 7: Tap follow button to unfollow
           await $.tap(followButton);
           await $.pump(); // Start optimistic update

           // Step 8: Verify optimistic UI update (button changes to "Follow" immediately)
           await $.pump(Duration(milliseconds: 100));
           final updatedButtonText = $.tester.widget<Text>(
             find.descendant(of: followButton, matching: find.byType(Text))
           );
           expect(updatedButtonText.data, 'Follow', reason: 'Button should change to "Follow" optimistically');

           // Step 9: Wait for API request to complete
           await $.pumpAndSettle(timeout: Duration(seconds: 5));

           // Step 10: Verify database has removed following record
           await test.verifyNotFollowingInDatabase(userId, followedCreatorId);

           // Step 11: Verify UI still shows unfollow state
           final finalButtonText = $.tester.widget<Text>(
             find.descendant(of: followButton, matching: find.byType(Text))
           );
           expect(finalButtonText.data, 'Follow', reason: 'Button should remain "Follow"');

         } finally {
           await test.tearDown();
         }
       },
     );

     class UnfollowWorkflowTest extends BaseE2ETest {
       Future<void> verifyNotFollowingInDatabase(String followerId, String followedId) async {
         final exists = await dbHelper.verifyRecordExists(
           'following',
           {'follower_id': followerId, 'followed_id': followedId}
         );
         expect(exists, false, reason: 'Following relationship should NOT exist in database after unfollow');
       }
     }
     ```

3. **Create E2E test for following state persistence across app restarts**
   - Add to same file:
     ```dart
     patrolTest(
       'Following state persists across app restarts',
       tags: ['tdd_red', 'e2e', 'following', 'persistence'],
       ($) async {
         final test = FollowingPersistenceTest();
         await test.setUp();

         try {
           // Step 1: Login and follow a creator
           await test.authHelper.ensureLoggedInAs('user3');
           final userId = await test.authHelper.getCurrentUserId();

           await $.pumpWidgetAndSettle(MyApp());

           final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
           final creatorId = firstFlyerCard.creatorId;

           final followButton = find.byKey(Key('follow_button_$creatorId'));
           await $.tap(followButton);
           await $.pumpAndSettle(timeout: Duration(seconds: 5));

           // Verify following in database
           await test.verifyFollowingInDatabase(userId, creatorId);

           // Step 2: Close app (simulate app termination)
           await $.tester.pumpWidget(Container());
           await $.pump(Duration(seconds: 1));

           // Step 3: Reopen app (re-launch)
           await $.pumpWidgetAndSettle(MyApp());

           // Wait for app to load and fetch flyers
           await $.pump(Duration(seconds: 2));
           await $.pumpAndSettle();

           // Step 4: Find a flyer from the followed creator
           final reloadedFlyerCard = find.byKey(Key('flyer_creator_$creatorId')).first;

           // Step 5: Verify follow button shows "Following" state (state persisted)
           final followButtonAfterRestart = find.descendant(
             of: reloadedFlyerCard,
             matching: find.byKey(Key('follow_button_$creatorId'))
           );

           final buttonTextAfterRestart = $.tester.widget<Text>(
             find.descendant(of: followButtonAfterRestart, matching: find.byType(Text))
           );
           expect(buttonTextAfterRestart.data, 'Following', reason: 'Following state should persist after app restart');

           // Step 6: Verify still in database
           await test.verifyFollowingInDatabase(userId, creatorId);

         } finally {
           await test.tearDown();
         }
       },
     );

     class FollowingPersistenceTest extends BaseE2ETest {}
     ```

4. **Create E2E test for anonymous user auth gate for following**
   - Create `pockitflyer_app/integration_test/e2e/following/follow_auth_gate_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';
     import '../config/e2e_test_config.dart';

     void main() {
       patrolTest(
         'Anonymous user sees login prompt when tapping follow button',
         tags: ['tdd_red', 'e2e', 'following', 'auth_gate'],
         ($) async {
           final test = FollowAuthGateTest();
           await test.setUp();

           try {
             // Step 1: Ensure user is logged out (anonymous)
             await test.authHelper.logoutAndClearState();

             // Step 2: Launch app as anonymous user
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Browse feed (should work for anonymous users)
             expect(find.byType(FlyerCard), findsWidgets, reason: 'Anonymous users can browse feed');

             // Step 4: Find first flyer and follow button
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final creatorId = firstFlyerCard.creatorId;
             final followButton = find.byKey(Key('follow_button_$creatorId'));

             // Step 5: Tap follow button
             await $.tap(followButton);
             await $.pumpAndSettle();

             // Step 6: Verify login prompt appears
             expect(find.text('Login Required'), findsOneWidget, reason: 'Should show login prompt title');
             expect(
               find.textContaining('follow creators'),
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

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Anonymous user can complete login flow from follow auth gate',
         tags: ['tdd_red', 'e2e', 'following', 'auth_gate', 'login_flow'],
         ($) async {
           final test = FollowAuthGateLoginTest();
           await test.setUp();

           try {
             // Step 1: Ensure user is logged out
             await test.authHelper.logoutAndClearState();

             // Step 2: Launch app and navigate to feed
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Tap follow button to trigger auth gate
             final firstFlyerCard = $.tester.widget(find.byType(FlyerCard).first);
             final creatorId = firstFlyerCard.creatorId;
             final followButton = find.byKey(Key('follow_button_$creatorId'));

             await $.tap(followButton);
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

             // Step 8: Verify follow action completed automatically
             final userId = await test.authHelper.getCurrentUserId();

             // Give app time to complete deferred follow action
             await $.pump(Duration(seconds: 2));
             await $.pumpAndSettle();

             // Step 9: Verify following relationship was created after login
             await test.verifyFollowingInDatabase(userId, creatorId);

             // Step 10: Verify UI shows following state
             final buttonText = $.tester.widget<Text>(
               find.descendant(
                 of: find.byKey(Key('follow_button_$creatorId')),
                 matching: find.byType(Text)
               )
             );
             expect(buttonText.data, 'Following', reason: 'Button should show "Following" after deferred action');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FollowAuthGateTest extends BaseE2ETest {}
     class FollowAuthGateLoginTest extends BaseE2ETest {}
     ```

5. **Create E2E test for following from creator profile page**
   - Create `pockitflyer_app/integration_test/e2e/following/follow_from_profile_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'User can follow creator from their profile page',
         tags: ['tdd_red', 'e2e', 'following', 'profile'],
         ($) async {
           final test = FollowFromProfileTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Find first flyer and tap to view details
             final firstFlyerCard = find.byType(FlyerCard).first;
             await $.tap(firstFlyerCard);
             await $.pumpAndSettle();

             // Step 3: Tap creator name/avatar to navigate to profile
             final creatorNameButton = find.byKey(Key('creator_name_button'));
             await $.tap(creatorNameButton);
             await $.pumpAndSettle();

             // Step 4: Verify on creator profile page
             expect(find.byType(CreatorProfilePage), findsOneWidget, reason: 'Should navigate to creator profile');

             // Step 5: Get creator ID from profile page
             final profilePage = $.tester.widget<CreatorProfilePage>(find.byType(CreatorProfilePage));
             final creatorId = profilePage.creatorId;

             // Step 6: Verify not following initially
             await test.verifyNotFollowingInDatabase(userId, creatorId);

             // Step 7: Find follow button on profile page
             final followButton = find.byKey(Key('profile_follow_button'));
             expect(followButton, findsOneWidget, reason: 'Profile should have follow button');

             // Step 8: Tap follow button
             await $.tap(followButton);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 9: Verify following relationship created
             await test.verifyFollowingInDatabase(userId, creatorId);

             // Step 10: Navigate back to feed
             await $.tap(find.byKey(Key('back_button')));
             await $.pumpAndSettle();
             await $.tap(find.byKey(Key('back_button'))); // Back from flyer details
             await $.pumpAndSettle();

             // Step 11: Verify flyer cards from this creator now show "Following" state
             final creatorFlyerCard = find.byKey(Key('flyer_creator_$creatorId')).first;
             final followButtonInFeed = find.descendant(
               of: creatorFlyerCard,
               matching: find.byKey(Key('follow_button_$creatorId'))
             );

             final buttonText = $.tester.widget<Text>(
               find.descendant(of: followButtonInFeed, matching: find.byType(Text))
             );
             expect(buttonText.data, 'Following', reason: 'Feed should reflect following state from profile action');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FollowFromProfileTest extends BaseE2ETest {
       Future<void> verifyNotFollowingInDatabase(String followerId, String followedId) async {
         final exists = await dbHelper.verifyRecordExists(
           'following',
           {'follower_id': followerId, 'followed_id': followedId}
         );
         expect(exists, false, reason: 'Following relationship should NOT exist initially');
       }
     }
     ```

6. **Create E2E test for multiple follows workflow**
   - Create `pockitflyer_app/integration_test/e2e/following/multiple_follows_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'User can follow multiple creators in sequence',
         tags: ['tdd_red', 'e2e', 'following'],
         ($) async {
           final test = MultipleFollowsTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user3');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Collect unique creator IDs from first 10 flyers
             final flyerCards = find.byType(FlyerCard);
             final creatorIds = <String>{};

             for (int i = 0; i < 10 && creatorIds.length < 5; i++) {
               final flyerCard = $.tester.widget(flyerCards.at(i));
               creatorIds.add(flyerCard.creatorId);
             }

             expect(creatorIds.length, greaterThanOrEqualTo(3), reason: 'Should have multiple unique creators');

             // Step 3: Follow all collected creators
             for (final creatorId in creatorIds) {
               final followButton = find.byKey(Key('follow_button_$creatorId')).first;
               await $.scrollUntilVisible(finder: followButton);
               await $.tap(followButton);
               await $.pump(Duration(milliseconds: 500)); // Brief pause between follows
             }

             // Step 4: Wait for all API requests to complete
             await $.pumpAndSettle(timeout: Duration(seconds: 10));

             // Step 5: Verify all following relationships exist in database
             for (final creatorId in creatorIds) {
               await test.verifyFollowingInDatabase(userId, creatorId);
             }

             // Step 6: Verify all follow buttons show "Following" state
             for (final creatorId in creatorIds) {
               final followButton = find.byKey(Key('follow_button_$creatorId')).first;
               await $.scrollUntilVisible(finder: followButton);

               final buttonText = $.tester.widget<Text>(
                 find.descendant(of: followButton, matching: find.byType(Text))
               );
               expect(buttonText.data, 'Following', reason: 'Creator $creatorId should show "Following"');
             }

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class MultipleFollowsTest extends BaseE2ETest {}
     ```

7. **Add database helper methods for following verification**
   - Update `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart`:
     - Add method: `Future<String?> getFirstFollowedCreatorForUser(String userId)` - returns creatorId of first followed creator
     - Add method: `Future<List<String>> getAllFollowedCreatorIdsForUser(String userId)` - returns all followed creator IDs
     - Add method: `Future<int> getFollowingCountForUser(String userId)` - returns count of follows

8. **Run all following E2E tests and mark green when passing**
   - Execute: `flutter test integration_test/e2e/following/ --tags=e2e`
   - Verify all tests pass against real backend
   - Update test tags from `tdd_red` to `tdd_green` in all passing tests
   - Commit with markers updated

### Acceptance Criteria
- [ ] Authenticated user can follow a creator with database persistence [Test: follow_workflow_test - follow path]
- [ ] Authenticated user can unfollow a creator with database removal [Test: follow_workflow_test - unfollow path]
- [ ] Optimistic UI updates occur immediately before API completes [Test: verify button text changes before pumpAndSettle]
- [ ] Following state persists across app restarts [Test: persistence test closes/reopens app, verifies state]
- [ ] Anonymous users see login prompt when tapping follow [Test: auth_gate_test - anonymous tap follow]
- [ ] Anonymous users can complete login from auth gate and follow action completes [Test: auth_gate_test - login flow]
- [ ] User can follow creator from profile page and state reflects in feed [Test: follow_from_profile_test]
- [ ] Multiple creators can be followed in sequence [Test: multiple_follows_test - 5 sequential follows]
- [ ] Database verification confirms all following operations [Test: all tests use verifyFollowingInDatabase]
- [ ] All E2E tests pass with real backend [Test: `flutter test integration_test/e2e/following/` exits 0]
- [ ] Tests marked `tdd_green` after passing [Test: inspect test files, verify markers]

### Files to Create/Modify

**Flutter E2E Tests:**
- `pockitflyer_app/integration_test/e2e/following/follow_workflow_test.dart` - NEW: Follow/unfollow/persistence tests
- `pockitflyer_app/integration_test/e2e/following/follow_auth_gate_test.dart` - NEW: Anonymous user auth gate tests
- `pockitflyer_app/integration_test/e2e/following/follow_from_profile_test.dart` - NEW: Follow from creator profile test
- `pockitflyer_app/integration_test/e2e/following/multiple_follows_test.dart` - NEW: Multiple follows workflow test
- `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart` - MODIFY: Add following-specific query methods

### Testing Requirements

**E2E Tests (Real Backend - NO MOCKS):**
- All tests run against real Django server started via m03-e04-t01 scripts
- All tests verify database state using real SQL queries
- All tests use real JWT authentication tokens
- Tests cover happy path (follow/unfollow) and auth gate scenarios
- Tests verify optimistic UI updates and eventual consistency
- Tests verify persistence across app restarts
- Tests verify following from both feed and profile page
- All tests tagged `e2e` and `following`
- Initial marker: `tdd_red`, change to `tdd_green` after verification

### Definition of Done
- [ ] All E2E tests written and pass against real backend
- [ ] Database verification confirms all following operations
- [ ] Optimistic UI updates work correctly
- [ ] Auth gate redirects anonymous users to login
- [ ] Persistence across app restarts works
- [ ] Following from profile page reflects in feed
- [ ] No console errors or warnings during test execution
- [ ] All tests marked `tdd_green` after passing
- [ ] Changes committed with reference to task ID (m03-e04-t03)

## Dependencies
- Requires: m03-e04-t01 (E2E test environment setup) - Infrastructure must exist
- Requires: M03-E02 (Creator following) - Feature implementation must be complete
- Requires: M01-E06 (Creator profile page) - Profile navigation must work
- Requires: M02-E01 (Authentication) - Login flow must work
- Blocks: m03-e04-t04 (Relationship filtering) - Filtering tests need following relationships
- Blocks: m03-e04-t05 (Error handling) - Some error tests build on following scenarios

## Technical Notes

**CRITICAL: Real Backend Required**
- Backend server must be running: `cd pockitflyer_backend && ./scripts/run_e2e_server.sh`
- Tests will fail if backend is not accessible on http://localhost:8001
- Database must have seed data (user1 with follows, user3 clean slate)

**Optimistic UI Testing Strategy:**
- Tests verify UI updates BEFORE `pumpAndSettle()` (optimistic update)
- Tests verify UI still correct AFTER `pumpAndSettle()` (server confirmation)
- Button text: "Follow" → "Following" (following) or "Following" → "Follow" (unfollowing)

**Database Verification Pattern:**
```dart
// Always verify both UI state AND database state
await test.verifyFollowingInDatabase(userId, creatorId); // Database
expect(buttonText.data, 'Following'); // UI
```

**Creator Profile Integration:**
- Following from profile page should sync with feed UI state
- Both profile page and feed cards should show same following state
- State management must handle follow/unfollow from multiple UI entry points
- Test validates this cross-component state consistency

**Widget Keys for Testing:**
- Ensure all follow buttons have unique keys: `Key('follow_button_$creatorId')`
- Ensure flyer cards include creator ID: `Key('flyer_creator_$creatorId')`
- Profile page follow button: `Key('profile_follow_button')`
- This allows tests to target specific creators reliably

**Multiple Creators in Feed:**
- Seed data should include flyers from multiple creators
- Some flyers from same creator (to test deduplication if needed)
- Tests collect unique creator IDs to verify diverse following relationships

**Auth Gate Deferred Action:**
- When anonymous user taps follow → login prompt appears
- User completes login
- App should "remember" the original follow action and complete it after login
- If not implemented, document as known limitation

## References
- Patrol testing patterns: https://patrol.leancode.co/
- Flutter integration test best practices: https://docs.flutter.dev/testing/integration-tests
- Optimistic UI patterns in the codebase (M03-E02 implementation)
- Auth gate implementation (M03-E02 task files)
- Creator profile navigation (M01-E06 implementation)
