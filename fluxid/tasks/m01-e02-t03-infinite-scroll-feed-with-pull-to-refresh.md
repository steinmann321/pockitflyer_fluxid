---
id: m01-e02-t03
title: Infinite Scroll Feed with Pull-to-Refresh
epic: m01-e02
milestone: m01
status: pending
---

# Task: Infinite Scroll Feed with Pull-to-Refresh

## Context
Part of Core Feed Display and Interaction (m01-e02) in Browse and Discover Local Flyers (m01).

Implements the core scrolling feed mechanism that displays flyer cards using infinite scroll pagination and manual refresh via pull-to-refresh gesture. This task focuses on the feed container and loading logic, while flyer card content is implemented separately in m01-e02-t04.

## Implementation Guide for LLM Agent

### Objective
Create an infinite scroll feed widget that loads flyers in pages, supports pull-to-refresh, and handles loading, error, and empty states gracefully.

### Steps
1. Create flyer model in `lib/features/feed/domain/models/flyer_model.dart`:
   - Use freezed and json_serializable for immutability
   - Fields: id, creatorId, creatorName, creatorAvatarUrl, images (List<String>), location (address string), distance (double?), title, description, infoField1, infoField2, validFrom (DateTime), validUntil (DateTime), categoryTags (List<String>)
   - Add fromJson/toJson methods
   - Run build_runner to generate freezed/json code: `flutter pub run build_runner build --delete-conflicting-outputs`

2. Create creator model in `lib/features/feed/domain/models/creator_model.dart`:
   - Use freezed and json_serializable
   - Fields: id, name, avatarUrl
   - Add fromJson/toJson methods

3. Create mock flyer repository in `lib/features/feed/data/repositories/flyer_repository.dart`:
   - Abstract class with method: `Future<List<FlyerModel>> getFlyers({required int page, required int pageSize})`
   - Create implementation `MockFlyerRepository` that returns fake data
   - Generate 30+ mock flyers with varied data (different creators, locations, dates, tags)
   - Simulate network delay with `await Future.delayed(Duration(milliseconds: 500))`
   - Implement pagination: return 10 flyers per page, empty list after page 3

4. Create Riverpod provider for repository in `lib/features/feed/data/repositories/providers.dart`:
   - Define `flyerRepositoryProvider` using Provider
   - Returns MockFlyerRepository instance

5. Create feed state notifier in `lib/features/feed/presentation/providers/feed_provider.dart`:
   - Create FeedState class with freezed: `@freezed class FeedState with _$FeedState`
   - State fields: flyers (List<FlyerModel>), isLoading (bool), isLoadingMore (bool), hasMore (bool), error (String?)
   - Create StateNotifier `FeedNotifier extends StateNotifier<FeedState>`
   - Methods:
     - `loadInitialFlyers()`: Load first page, set isLoading
     - `loadMoreFlyers()`: Load next page if hasMore, set isLoadingMore
     - `refreshFlyers()`: Reset to first page, reload
   - Use repository from flyerRepositoryProvider
   - Track current page number
   - Handle errors and update error state

6. Create provider for feed notifier:
   - `final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) => FeedNotifier(ref.read(flyerRepositoryProvider)))`

7. Create feed widget in `lib/features/feed/presentation/widgets/feed_list.dart`:
   - ConsumerWidget that watches feedProvider
   - Use RefreshIndicator for pull-to-refresh
   - OnRefresh: call `ref.read(feedProvider.notifier).refreshFlyers()`
   - Use ListView.builder for infinite scroll
   - ItemCount: `state.flyers.length + 1` (extra item for loading indicator)
   - ItemBuilder:
     - If index < flyers.length: return FlyerCard(flyer: state.flyers[index])
     - If index == flyers.length: return loading indicator or "No more flyers" message
   - Scroll listener: detect when user reaches bottom (~90% scroll position), call loadMoreFlyers()

8. Create loading states in `lib/features/feed/presentation/widgets/feed_loading_states.dart`:
   - `FeedLoadingIndicator`: Shows circular progress during initial load
   - `FeedLoadingMoreIndicator`: Small loading indicator at bottom during pagination
   - `FeedEmptyState`: Message when no flyers available ("No flyers found")
   - `FeedErrorState`: Error message with retry button

9. Update `lib/features/feed/presentation/screens/feed_screen.dart`:
   - Replace placeholder content with FeedList widget
   - Structure:
     ```dart
     Column(
       children: [
         AppHeader(), // from m01-e02-t02
         Expanded(
           child: Consumer(
             builder: (context, ref, child) {
               final state = ref.watch(feedProvider);
               if (state.isLoading && state.flyers.isEmpty) {
                 return FeedLoadingIndicator();
               }
               if (state.error != null && state.flyers.isEmpty) {
                 return FeedErrorState(
                   error: state.error!,
                   onRetry: () => ref.read(feedProvider.notifier).loadInitialFlyers(),
                 );
               }
               if (state.flyers.isEmpty) {
                 return FeedEmptyState();
               }
               return FeedList();
             },
           ),
         ),
       ],
     )
     ```

10. Implement scroll detection for infinite scroll:
    - Use NotificationListener<ScrollNotification> wrapping ListView
    - When user scrolls to 90% of content, trigger loadMoreFlyers()
    - Prevent multiple simultaneous load calls (check isLoadingMore)

11. Create placeholder flyer card in `lib/features/feed/presentation/widgets/flyer_card.dart`:
    - Simple Container with Card showing flyer title and creator name
    - Full implementation will be in m01-e02-t04
    - This allows testing feed functionality without complete card design

12. Create unit tests in `test/features/feed/domain/models/`:
    - Test FlyerModel fromJson/toJson
    - Test CreatorModel fromJson/toJson
    - Test model equality with freezed

13. Create unit tests in `test/features/feed/data/repositories/`:
    - Test MockFlyerRepository returns correct page size
    - Test pagination works (page 1, 2, 3)
    - Test returns empty after page 3
    - Test simulated delay exists

14. Create unit tests in `test/features/feed/presentation/providers/`:
    - Test FeedNotifier loadInitialFlyers() updates state correctly
    - Test loadMoreFlyers() appends flyers
    - Test refreshFlyers() resets to first page
    - Test hasMore flag is set correctly
    - Test error handling updates error state

15. Create widget tests in `test/features/feed/presentation/widgets/`:
    - Test FeedList renders list of flyers
    - Test pull-to-refresh calls refreshFlyers()
    - Test scroll to bottom triggers loadMoreFlyers()
    - Test loading states display correctly
    - Test empty state displays when no flyers
    - Test error state displays with retry button

### Acceptance Criteria
- [ ] Feed displays list of mock flyers on app launch [Test: run app, see flyers]
- [ ] Pull-to-refresh reloads feed from first page [Test: swipe down, observe loading indicator and refresh]
- [ ] Scrolling to bottom loads next page [Test: scroll to end, see loading indicator and new flyers appear]
- [ ] Pagination stops after 3 pages with "No more flyers" message [Test: load all pages]
- [ ] Initial loading state shows centered progress indicator [Test: cold start with network delay]
- [ ] Empty state displays when no flyers [Test: mock empty response]
- [ ] Error state shows with retry button [Test: mock error response, tap retry]
- [ ] Smooth 60fps scrolling performance [Test: visual inspection, no jank]
- [ ] No duplicate flyers loaded during pagination [Test: verify flyer IDs are unique]
- [ ] Unit and widget tests pass with >85% coverage [Test: `flutter test --coverage`]

### Files to Create/Modify
- `pockitflyer_app/lib/features/feed/domain/models/flyer_model.dart` - NEW: flyer data model
- `pockitflyer_app/lib/features/feed/domain/models/flyer_model.freezed.dart` - GENERATED: freezed code
- `pockitflyer_app/lib/features/feed/domain/models/flyer_model.g.dart` - GENERATED: json code
- `pockitflyer_app/lib/features/feed/domain/models/creator_model.dart` - NEW: creator data model
- `pockitflyer_app/lib/features/feed/domain/models/creator_model.freezed.dart` - GENERATED: freezed code
- `pockitflyer_app/lib/features/feed/domain/models/creator_model.g.dart` - GENERATED: json code
- `pockitflyer_app/lib/features/feed/data/repositories/flyer_repository.dart` - NEW: repository interface and mock
- `pockitflyer_app/lib/features/feed/data/repositories/providers.dart` - NEW: repository provider
- `pockitflyer_app/lib/features/feed/presentation/providers/feed_provider.dart` - NEW: feed state notifier
- `pockitflyer_app/lib/features/feed/presentation/widgets/feed_list.dart` - NEW: scrollable feed widget
- `pockitflyer_app/lib/features/feed/presentation/widgets/feed_loading_states.dart` - NEW: loading/error/empty states
- `pockitflyer_app/lib/features/feed/presentation/widgets/flyer_card.dart` - NEW: placeholder card widget
- `pockitflyer_app/lib/features/feed/presentation/screens/feed_screen.dart` - MODIFY: integrate feed list
- `pockitflyer_app/test/features/feed/domain/models/flyer_model_test.dart` - NEW: model tests
- `pockitflyer_app/test/features/feed/domain/models/creator_model_test.dart` - NEW: model tests
- `pockitflyer_app/test/features/feed/data/repositories/flyer_repository_test.dart` - NEW: repository tests
- `pockitflyer_app/test/features/feed/presentation/providers/feed_provider_test.dart` - NEW: notifier tests
- `pockitflyer_app/test/features/feed/presentation/widgets/feed_list_test.dart` - NEW: feed widget tests

### Testing Requirements
- **Unit tests**: FlyerModel, CreatorModel (fromJson/toJson, equality), MockFlyerRepository (pagination, data), FeedNotifier (state management, loading, refresh, pagination logic)
- **Widget tests**: FeedList (render items, pull-to-refresh gesture, scroll behavior), loading states (initial, loading more, empty, error)
- **Integration tests**: Full feed flow with mocked repository (load initial → scroll → load more → refresh)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter state management best practices (Riverpod)
- [ ] No console errors or warnings
- [ ] Scrolling is smooth without performance issues
- [ ] Mock data is realistic and varied (different creators, dates, locations)
- [ ] Comments added for pagination logic and scroll detection
- [ ] Changes committed with reference to task ID (m01-e02-t03)
- [ ] Ready for flyer card implementation (m01-e02-t04)

## Dependencies
- Requires: m01-e02-t01 (app structure), m01-e02-t02 (header component)
- Blocks: m01-e02-t04 (flyer card content - placeholder card used here)

## Technical Notes
- **Pagination**: Use cursor-based or offset-based pagination. Offset (page number) is simpler for mock data
- **Scroll detection**: Use NotificationListener<ScrollNotification> to detect when user is near bottom (≥90% scrolled)
- **Pull-to-refresh**: Use RefreshIndicator widget (Material Design standard)
- **Freezed**: Run `flutter pub run build_runner build` to generate code after creating models
- **Mock data**: Generate realistic data with various category tags, dates (past/future), locations, distances (1-50km)
- **Performance**: ListView.builder is efficient for large lists (only builds visible items)
- **State management**: Riverpod StateNotifier pattern for complex state with loading/error handling
- **Error handling**: Catch errors from repository, update error state, provide retry mechanism
- **Loading indicators**: Use CircularProgressIndicator for loading states
- **Empty state**: Friendly message, not just blank screen

## References
- Riverpod StateNotifier: https://riverpod.dev/docs/providers/state_notifier_provider
- Freezed package: https://pub.dev/packages/freezed
- ListView.builder: https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html
- RefreshIndicator: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
- Infinite scroll pattern: https://docs.flutter.dev/cookbook/lists/long-lists
