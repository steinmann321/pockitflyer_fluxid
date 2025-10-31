---
id: m03-e04-t04
title: Relationship Filtering User Journey Validation (E2E)
epic: m03-e04
milestone: m03
status: pending
---

# Task: Relationship Filtering User Journey Validation (E2E)

## Context
Part of E2E Milestone Validation (m03-e04) in Milestone m03 (Personalized Feed - Favorites & Following).

This task validates the complete relationship filtering user journey end-to-end with REAL backend, REAL database, and REAL authentication. Tests verify that authenticated users can filter feeds by favorites and following, combine filters with categories, see correct results, and verify database queries are optimized with proper JOINs.

**CRITICAL**: This uses the E2E infrastructure from m03-e04-t01. All tests run against real Django backend with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create comprehensive E2E tests that validate relationship filtering workflows including single filters (Favorites/Following), combined filters (Favorites + Events, Following + Sales), query optimization verification, and filter state management, using real backend services and database verification.

### Steps

1. **Create E2E test for favorites-only filter**
   - Create `pockitflyer_app/integration_test/e2e/filtering/favorites_filter_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Favorites filter shows only favorited flyers',
         tags: ['tdd_red', 'e2e', 'filtering', 'favorites'],
         ($) async {
           final test = FavoritesFilterTest();
           await test.setUp();

           try {
             // Step 1: Login as user1 (has existing favorites from seed data)
             await test.authHelper.ensureLoggedInAs('user1');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Get all favorited flyer IDs from database
             final favoritedFlyerIds = await test.dbHelper.getAllFavoritedFlyerIdsForUser(userId);
             expect(favoritedFlyerIds.length, greaterThan(0), reason: 'User1 should have favorites from seed data');

             // Step 3: Count total flyers in unfiltered feed
             final unfilteredFlyerCards = find.byType(FlyerCard);
             final unfilteredCount = $.tester.widgetList(unfilteredFlyerCards).length;
             expect(unfilteredCount, greaterThan(favoritedFlyerIds.length), reason: 'Unfiltered feed should have more flyers than favorites');

             // Step 4: Open filter menu
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             // Step 5: Tap "Favorites" filter chip
             final favoritesChip = find.byKey(Key('filter_chip_favorites'));
             expect(favoritesChip, findsOneWidget, reason: 'Favorites filter chip should exist');
             await $.tap(favoritesChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 6: Verify filter chip is selected (visual state)
             final favoritesChipWidget = $.tester.widget<FilterChip>(favoritesChip);
             expect(favoritesChipWidget.selected, true, reason: 'Favorites chip should be selected');

             // Step 7: Verify feed shows only favorited flyers
             final filteredFlyerCards = find.byType(FlyerCard);
             final filteredCount = $.tester.widgetList(filteredFlyerCards).length;
             expect(filteredCount, equals(favoritedFlyerIds.length), reason: 'Filtered feed should show exact number of favorited flyers');

             // Step 8: Verify each displayed flyer is in favorites list
             for (int i = 0; i < filteredCount; i++) {
               final flyerCard = $.tester.widget(filteredFlyerCards.at(i));
               final flyerId = flyerCard.flyerId;
               expect(favoritedFlyerIds.contains(flyerId), true, reason: 'Flyer $flyerId should be in favorites list');
             }

             // Step 9: Verify backend database query uses JOIN
             final queryLog = await test.dbHelper.getLastQueryLog();
             expect(queryLog, contains('JOIN favorites'), reason: 'Query should use JOIN on favorites table');
             expect(queryLog, contains('WHERE favorites.user_id'), reason: 'Query should filter by user_id');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FavoritesFilterTest extends BaseE2ETest {}
     ```

2. **Create E2E test for following-only filter**
   - Create `pockitflyer_app/integration_test/e2e/filtering/following_filter_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Following filter shows only followed creators flyers',
         tags: ['tdd_red', 'e2e', 'filtering', 'following'],
         ($) async {
           final test = FollowingFilterTest();
           await test.setUp();

           try {
             // Step 1: Login as user1 (has existing follows from seed data)
             await test.authHelper.ensureLoggedInAs('user1');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Get all followed creator IDs from database
             final followedCreatorIds = await test.dbHelper.getAllFollowedCreatorIdsForUser(userId);
             expect(followedCreatorIds.length, greaterThan(0), reason: 'User1 should have follows from seed data');

             // Step 3: Count total flyers in unfiltered feed
             final unfilteredFlyerCards = find.byType(FlyerCard);
             final unfilteredCount = $.tester.widgetList(unfilteredFlyerCards).length;

             // Step 4: Open filter menu and tap "Following" filter chip
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final followingChip = find.byKey(Key('filter_chip_following'));
             expect(followingChip, findsOneWidget, reason: 'Following filter chip should exist');
             await $.tap(followingChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 5: Verify filter chip is selected
             final followingChipWidget = $.tester.widget<FilterChip>(followingChip);
             expect(followingChipWidget.selected, true, reason: 'Following chip should be selected');

             // Step 6: Verify feed shows only followed creators' flyers
             final filteredFlyerCards = find.byType(FlyerCard);
             final filteredCount = $.tester.widgetList(filteredFlyerCards).length;
             expect(filteredCount, greaterThan(0), reason: 'Filtered feed should show followed creators flyers');
             expect(filteredCount, lessThan(unfilteredCount), reason: 'Filtered feed should have fewer flyers than unfiltered');

             // Step 7: Verify each displayed flyer is from a followed creator
             for (int i = 0; i < filteredCount; i++) {
               final flyerCard = $.tester.widget(filteredFlyerCards.at(i));
               final creatorId = flyerCard.creatorId;
               expect(followedCreatorIds.contains(creatorId), true, reason: 'Flyer creator $creatorId should be in following list');
             }

             // Step 8: Verify backend database query uses JOIN
             final queryLog = await test.dbHelper.getLastQueryLog();
             expect(queryLog, contains('JOIN following'), reason: 'Query should use JOIN on following table');
             expect(queryLog, contains('WHERE following.follower_id'), reason: 'Query should filter by follower_id');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FollowingFilterTest extends BaseE2ETest {}
     ```

3. **Create E2E test for combined relationship + category filters**
   - Create `pockitflyer_app/integration_test/e2e/filtering/combined_filters_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Favorites + Events filter shows only favorited event flyers',
         tags: ['tdd_red', 'e2e', 'filtering', 'combined'],
         ($) async {
           final test = CombinedFavoritesEventsFilterTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user1');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Get favorited flyer IDs and filter for Events category
             final allFavoritedFlyerIds = await test.dbHelper.getAllFavoritedFlyerIdsForUser(userId);
             final favoritedEventFlyerIds = await test.dbHelper.getFlyerIdsByCategory(allFavoritedFlyerIds, 'Events');

             // Step 3: Open filter menu
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             // Step 4: Select both "Favorites" and "Events" filters
             final favoritesChip = find.byKey(Key('filter_chip_favorites'));
             await $.tap(favoritesChip);
             await $.pump(Duration(milliseconds: 300));

             final eventsChip = find.byKey(Key('filter_chip_events'));
             await $.tap(eventsChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 5: Verify both chips are selected
             final favoritesChipWidget = $.tester.widget<FilterChip>(favoritesChip);
             final eventsChipWidget = $.tester.widget<FilterChip>(eventsChip);
             expect(favoritesChipWidget.selected, true, reason: 'Favorites chip should be selected');
             expect(eventsChipWidget.selected, true, reason: 'Events chip should be selected');

             // Step 6: Verify feed shows only favorited event flyers
             final filteredFlyerCards = find.byType(FlyerCard);
             final filteredCount = $.tester.widgetList(filteredFlyerCards).length;

             if (favoritedEventFlyerIds.isEmpty) {
               // Edge case: no favorited events exist
               expect(filteredCount, equals(0), reason: 'Should show empty state when no favorited events exist');
               expect(find.text('No flyers match your filters'), findsOneWidget, reason: 'Should show empty state message');
             } else {
               expect(filteredCount, equals(favoritedEventFlyerIds.length), reason: 'Should show exact count of favorited event flyers');

               // Step 7: Verify each displayed flyer is both favorited AND event category
               for (int i = 0; i < filteredCount; i++) {
                 final flyerCard = $.tester.widget(filteredFlyerCards.at(i));
                 final flyerId = flyerCard.flyerId;
                 expect(favoritedEventFlyerIds.contains(flyerId), true, reason: 'Flyer $flyerId should be favorited event');
               }
             }

             // Step 8: Verify backend query uses both JOIN and WHERE clauses
             final queryLog = await test.dbHelper.getLastQueryLog();
             expect(queryLog, contains('JOIN favorites'), reason: 'Query should JOIN favorites table');
             expect(queryLog, contains('WHERE'), reason: 'Query should have WHERE clause for category');
             expect(queryLog, contains('category'), reason: 'Query should filter by category');

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Following + Sales filter shows only followed creators sale flyers',
         tags: ['tdd_red', 'e2e', 'filtering', 'combined'],
         ($) async {
           final test = CombinedFollowingSalesFilterTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user1');
             final userId = await test.authHelper.getCurrentUserId();

             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Get followed creator IDs
             final followedCreatorIds = await test.dbHelper.getAllFollowedCreatorIdsForUser(userId);

             // Step 3: Open filter menu
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             // Step 4: Select both "Following" and "Sales" filters
             final followingChip = find.byKey(Key('filter_chip_following'));
             await $.tap(followingChip);
             await $.pump(Duration(milliseconds: 300));

             final salesChip = find.byKey(Key('filter_chip_sales'));
             await $.tap(salesChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 5: Verify both chips are selected
             final followingChipWidget = $.tester.widget<FilterChip>(followingChip);
             final salesChipWidget = $.tester.widget<FilterChip>(salesChip);
             expect(followingChipWidget.selected, true, reason: 'Following chip should be selected');
             expect(salesChipWidget.selected, true, reason: 'Sales chip should be selected');

             // Step 6: Verify feed shows only followed creators' sale flyers
             final filteredFlyerCards = find.byType(FlyerCard);
             final filteredCount = $.tester.widgetList(filteredFlyerCards).length;

             // Step 7: Verify each displayed flyer is from followed creator AND sales category
             for (int i = 0; i < filteredCount; i++) {
               final flyerCard = $.tester.widget(filteredFlyerCards.at(i));
               final creatorId = flyerCard.creatorId;
               final category = flyerCard.category;

               expect(followedCreatorIds.contains(creatorId), true, reason: 'Creator $creatorId should be in following list');
               expect(category, equals('Sales'), reason: 'Flyer should be in Sales category');
             }

             // Step 8: Verify backend query uses both JOIN and WHERE clauses
             final queryLog = await test.dbHelper.getLastQueryLog();
             expect(queryLog, contains('JOIN following'), reason: 'Query should JOIN following table');
             expect(queryLog, contains('category'), reason: 'Query should filter by category');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class CombinedFavoritesEventsFilterTest extends BaseE2ETest {}
     class CombinedFollowingSalesFilterTest extends BaseE2ETest {}
     ```

4. **Create E2E test for filter state management**
   - Create `pockitflyer_app/integration_test/e2e/filtering/filter_state_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Filter state persists across feed refreshes',
         tags: ['tdd_red', 'e2e', 'filtering', 'state'],
         ($) async {
           final test = FilterStatePersistenceTest();
           await test.setUp();

           try {
             // Step 1: Login and apply filters
             await test.authHelper.ensureLoggedInAs('user1');
             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Apply Favorites filter
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final favoritesChip = find.byKey(Key('filter_chip_favorites'));
             await $.tap(favoritesChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 3: Count filtered results
             final initialFilteredCount = $.tester.widgetList(find.byType(FlyerCard)).length;

             // Step 4: Pull-to-refresh feed
             final scrollable = find.byType(Scrollable).first;
             await $.tester.fling(scrollable, Offset(0, 300), 1000); // Swipe down
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 5: Verify filter still applied (chip still selected)
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final favoritesChipAfterRefresh = $.tester.widget<FilterChip>(favoritesChip);
             expect(favoritesChipAfterRefresh.selected, true, reason: 'Filter should remain selected after refresh');

             // Step 6: Verify filtered count unchanged (same favorites)
             final afterRefreshCount = $.tester.widgetList(find.byType(FlyerCard)).length;
             expect(afterRefreshCount, equals(initialFilteredCount), reason: 'Filter should persist after refresh');

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'User can toggle filters on and off',
         tags: ['tdd_red', 'e2e', 'filtering', 'state'],
         ($) async {
           final test = FilterToggleTest();
           await test.setUp();

           try {
             // Step 1: Login
             await test.authHelper.ensureLoggedInAs('user1');
             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Count unfiltered flyers
             final unfilteredCount = $.tester.widgetList(find.byType(FlyerCard)).length;

             // Step 3: Apply Favorites filter
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final favoritesChip = find.byKey(Key('filter_chip_favorites'));
             await $.tap(favoritesChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 4: Verify filtered count is less
             final filteredCount = $.tester.widgetList(find.byType(FlyerCard)).length;
             expect(filteredCount, lessThan(unfilteredCount), reason: 'Filtered feed should have fewer flyers');

             // Step 5: Deselect filter (tap again to toggle off)
             await $.tap(filterButton);
             await $.pumpAndSettle();
             await $.tap(favoritesChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 6: Verify chip is deselected
             final favoritesChipDeselected = $.tester.widget<FilterChip>(favoritesChip);
             expect(favoritesChipDeselected.selected, false, reason: 'Filter should be deselected');

             // Step 7: Verify unfiltered count restored
             final restoredCount = $.tester.widgetList(find.byType(FlyerCard)).length;
             expect(restoredCount, equals(unfilteredCount), reason: 'Should show all flyers when filter removed');

           } finally {
             await test.tearDown();
           }
         },
       );

       patrolTest(
         'Filter state persists across app restarts',
         tags: ['tdd_red', 'e2e', 'filtering', 'state', 'persistence'],
         ($) async {
           final test = FilterAppRestartPersistenceTest();
           await test.setUp();

           try {
             // Step 1: Login and apply filters
             await test.authHelper.ensureLoggedInAs('user1');
             await $.pumpWidgetAndSettle(MyApp());

             // Step 2: Apply Following + Events filters
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final followingChip = find.byKey(Key('filter_chip_following'));
             await $.tap(followingChip);
             await $.pump(Duration(milliseconds: 300));

             final eventsChip = find.byKey(Key('filter_chip_events'));
             await $.tap(eventsChip);
             await $.pumpAndSettle(timeout: Duration(seconds: 5));

             // Step 3: Count filtered results
             final filteredCount = $.tester.widgetList(find.byType(FlyerCard)).length;

             // Step 4: Close and reopen app
             await $.tester.pumpWidget(Container());
             await $.pump(Duration(seconds: 1));
             await $.pumpWidgetAndSettle(MyApp());
             await $.pump(Duration(seconds: 2));
             await $.pumpAndSettle();

             // Step 5: Verify filters still applied
             await $.tap(filterButton);
             await $.pumpAndSettle();

             final followingChipAfterRestart = $.tester.widget<FilterChip>(followingChip);
             final eventsChipAfterRestart = $.tester.widget<FilterChip>(eventsChip);
             expect(followingChipAfterRestart.selected, true, reason: 'Following filter should persist after restart');
             expect(eventsChipAfterRestart.selected, true, reason: 'Events filter should persist after restart');

             // Step 6: Verify filtered count same
             final afterRestartCount = $.tester.widgetList(find.byType(FlyerCard)).length;
             expect(afterRestartCount, equals(filteredCount), reason: 'Filter results should persist after restart');

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FilterStatePersistenceTest extends BaseE2ETest {}
     class FilterToggleTest extends BaseE2ETest {}
     class FilterAppRestartPersistenceTest extends BaseE2ETest {}
     ```

5. **Create E2E test for anonymous user filter restrictions**
   - Create `pockitflyer_app/integration_test/e2e/filtering/filter_auth_gate_test.dart`:
     ```dart
     import 'package:flutter_test/flutter_test.dart';
     import 'package:patrol/patrol.dart';
     import '../base_e2e_test.dart';

     void main() {
       patrolTest(
         'Anonymous users see relationship filters disabled with explanation',
         tags: ['tdd_red', 'e2e', 'filtering', 'auth_gate'],
         ($) async {
           final test = FilterAuthGateTest();
           await test.setUp();

           try {
             // Step 1: Ensure logged out
             await test.authHelper.logoutAndClearState();

             // Step 2: Launch app
             await $.pumpWidgetAndSettle(MyApp());

             // Step 3: Open filter menu
             final filterButton = find.byKey(Key('filter_button'));
             await $.tap(filterButton);
             await $.pumpAndSettle();

             // Step 4: Verify category filters are enabled
             final eventsChip = find.byKey(Key('filter_chip_events'));
             final eventsChipWidget = $.tester.widget<FilterChip>(eventsChip);
             expect(eventsChipWidget.isEnabled, true, reason: 'Category filters should be enabled for anonymous users');

             // Step 5: Verify relationship filters are disabled
             final favoritesChip = find.byKey(Key('filter_chip_favorites'));
             final favoritesChipWidget = $.tester.widget<FilterChip>(favoritesChip);
             expect(favoritesChipWidget.isEnabled, false, reason: 'Favorites filter should be disabled for anonymous users');

             final followingChip = find.byKey(Key('filter_chip_following'));
             final followingChipWidget = $.tester.widget<FilterChip>(followingChip);
             expect(followingChipWidget.isEnabled, false, reason: 'Following filter should be disabled for anonymous users');

             // Step 6: Verify explanation tooltip or message
             await $.tap(favoritesChip); // Tap disabled chip
             await $.pumpAndSettle();

             expect(
               find.textContaining('Login to use this filter'),
               findsOneWidget,
               reason: 'Should show explanation why filter is disabled'
             );

           } finally {
             await test.tearDown();
           }
         },
       );
     }

     class FilterAuthGateTest extends BaseE2ETest {}
     ```

6. **Add database helper methods for filtering verification**
   - Update `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart`:
     - Add method: `Future<List<String>> getFlyerIdsByCategory(List<String> flyerIds, String category)` - filters flyer IDs by category
     - Add method: `Future<String> getLastQueryLog()` - retrieves last SQL query executed (requires backend support)
     - Add method: `Future<Map<String, dynamic>> getQueryAnalysis(String query)` - analyzes query performance (EXPLAIN)

7. **Add backend query logging support**
   - Update `pockitflyer_backend/e2e_server_config.py`:
     - Enable SQL query logging when E2E_TEST_MODE=true
     - Create endpoint: `GET /api/test/last-query` - returns last executed SQL query
     - Create endpoint: `GET /api/test/query-stats` - returns query count, avg time, etc.
     - Only enable these endpoints in E2E test mode (security)

8. **Run all filtering E2E tests and mark green when passing**
   - Execute: `flutter test integration_test/e2e/filtering/ --tags=e2e`
   - Verify all tests pass against real backend
   - Update test tags from `tdd_red` to `tdd_green` in all passing tests
   - Commit with markers updated

### Acceptance Criteria
- [ ] Favorites-only filter shows only favorited flyers with database JOIN [Test: favorites_filter_test]
- [ ] Following-only filter shows only followed creators' flyers with database JOIN [Test: following_filter_test]
- [ ] Combined Favorites + Events filter shows correct intersection [Test: combined_filters_test - favorites + events]
- [ ] Combined Following + Sales filter shows correct intersection [Test: combined_filters_test - following + sales]
- [ ] Database queries use proper JOINs (not N+1 queries) [Test: verify query logs contain JOIN statements]
- [ ] Filter state persists across pull-to-refresh [Test: filter_state_test - refresh persistence]
- [ ] Users can toggle filters on and off [Test: filter_state_test - toggle]
- [ ] Filter state persists across app restarts [Test: filter_state_test - app restart]
- [ ] Anonymous users see relationship filters disabled with explanation [Test: filter_auth_gate_test]
- [ ] All E2E tests pass with real backend [Test: `flutter test integration_test/e2e/filtering/` exits 0]
- [ ] Tests marked `tdd_green` after passing [Test: inspect test files, verify markers]

### Files to Create/Modify

**Flutter E2E Tests:**
- `pockitflyer_app/integration_test/e2e/filtering/favorites_filter_test.dart` - NEW: Favorites-only filter test
- `pockitflyer_app/integration_test/e2e/filtering/following_filter_test.dart` - NEW: Following-only filter test
- `pockitflyer_app/integration_test/e2e/filtering/combined_filters_test.dart` - NEW: Combined filter tests
- `pockitflyer_app/integration_test/e2e/filtering/filter_state_test.dart` - NEW: Filter state management tests
- `pockitflyer_app/integration_test/e2e/filtering/filter_auth_gate_test.dart` - NEW: Anonymous user filter restriction tests
- `pockitflyer_app/integration_test/e2e/helpers/database_helper.dart` - MODIFY: Add filtering-specific query methods

**Backend (Django):**
- `pockitflyer_backend/e2e_server_config.py` - MODIFY: Enable SQL query logging in E2E mode
- `pockitflyer_backend/api/test_endpoints.py` - NEW: Test-only endpoints for query inspection (last-query, query-stats)

### Testing Requirements

**E2E Tests (Real Backend - NO MOCKS):**
- All tests run against real Django server started via m03-e04-t01 scripts
- All tests verify database queries use proper JOINs (not N+1 queries)
- All tests verify correct result sets match filter criteria
- Tests cover single filters, combined filters, filter state management, and auth gates
- Tests verify filter persistence across refresh and app restart
- All tests tagged `e2e` and `filtering`
- Initial marker: `tdd_red`, change to `tdd_green` after verification

### Definition of Done
- [ ] All E2E tests written and pass against real backend
- [ ] Database queries verified to use proper JOINs
- [ ] Single and combined filters produce correct results
- [ ] Filter state persists across refresh and restart
- [ ] Anonymous users see appropriate filter restrictions
- [ ] No console errors or warnings during test execution
- [ ] All tests marked `tdd_green` after passing
- [ ] Backend query logging endpoints created for E2E mode
- [ ] Changes committed with reference to task ID (m03-e04-t04)

## Dependencies
- Requires: m03-e04-t01 (E2E test environment setup) - Infrastructure must exist
- Requires: m03-e04-t02 (Favorites E2E tests) - Favorites relationships must work
- Requires: m03-e04-t03 (Following E2E tests) - Following relationships must work
- Requires: M03-E03 (Relationship filtering) - Feature implementation must be complete
- Blocks: None (parallel with m03-e04-t05)

## Technical Notes

**CRITICAL: Real Backend Required**
- Backend server must be running: `cd pockitflyer_backend && ./scripts/run_e2e_server.sh`
- Backend must have query logging enabled in E2E mode
- Database must have seed data with diverse relationships (favorites, follows, categories)

**Query Optimization Verification:**
- Tests MUST verify database queries use JOINs, not multiple round-trips
- Backend should log executed SQL queries when E2E_TEST_MODE=true
- Test helper fetches query log via test-only endpoint
- Look for patterns:
  - ✅ GOOD: `SELECT * FROM flyers JOIN favorites ON ... WHERE favorites.user_id = ?`
  - ❌ BAD: Multiple `SELECT * FROM flyers WHERE id IN (...)` queries

**Combined Filter Logic:**
- Favorites + Category = flyers that are BOTH favorited AND in category (AND logic)
- Following + Category = flyers from followed creators AND in category (AND logic)
- Multiple categories = flyers in ANY selected category (OR logic within categories)
- Relationship filters are AND with category filters

**Filter State Persistence:**
- Filters stored in app state (provider, bloc, riverpod, etc.)
- Pull-to-refresh should maintain active filters
- App restart should restore filter state from local storage (shared preferences, hive, etc.)
- Verify implementation handles persistence correctly

**Anonymous User Restrictions:**
- Relationship filters (Favorites, Following) require authentication
- Category filters (Events, Sales, News, etc.) work for anonymous users
- Disabled filters should be visually distinct (grayed out, disabled state)
- Tapping disabled filters should show explanation, not login prompt (less aggressive UX)

**Empty State Handling:**
- If combined filters produce zero results, show appropriate empty state
- Message: "No flyers match your filters" or similar
- Option to adjust filters (clear filters button)

**Widget Keys for Testing:**
- Filter button: `Key('filter_button')`
- Filter chips: `Key('filter_chip_favorites')`, `Key('filter_chip_following')`, `Key('filter_chip_events')`, etc.
- This allows tests to target specific filters reliably

**Backend Test Endpoints Security:**
- `/api/test/last-query` and `/api/test/query-stats` ONLY enabled when E2E_TEST_MODE=true
- Return 403 Forbidden in production or dev mode
- Never expose in production builds

**Performance Considerations:**
- Filter queries should complete in <500ms even with 1000+ flyers
- Verify indexes exist on favorites.user_id, following.follower_id, flyers.category
- If tests are slow, investigate query performance with EXPLAIN

## References
- Django query optimization: https://docs.djangoproject.com/en/4.2/topics/db/optimization/
- Flutter FilterChip widget: https://api.flutter.dev/flutter/material/FilterChip-class.html
- State persistence patterns in codebase (M03-E03 implementation)
- Pull-to-refresh implementation (M01-E04 if exists)
