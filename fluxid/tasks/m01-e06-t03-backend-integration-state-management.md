---
id: m01-e06-t03
title: Backend Profile Endpoint Integration and State Management
epic: m01-e06
milestone: m01
status: pending
---

# Task: Backend Profile Endpoint Integration and State Management

## Context
Part of Creator Profile Viewing (m01-e06) in Browse and Discover Local Flyers (m01).

Integrates the profile page UI with the backend public profile endpoints, implements Riverpod state management for profile data and creator's flyers, adds API client methods, handles loading/error states, implements caching to avoid redundant requests, and manages pagination for creators with many flyers.

## Implementation Guide for LLM Agent

### Objective
Connect the profile page to backend API endpoints, implement Riverpod providers for state management, add API client integration, handle all states (loading, error, success, empty), and implement caching and pagination.

### Steps

1. Verify backend profile endpoint exists (from m01-e01-t02):
   - Check if `GET /api/creators/{id}/` endpoint returns creator profile
   - Check if `GET /api/creators/{id}/flyers/` endpoint returns creator's flyers
   - If endpoints don't exist, create them:
     - CreatorViewSet with `retrieve` action
     - Custom action `@action(detail=True, methods=['get'])` for `flyers`
     - File: `pockitflyer_backend/flyers/views.py`
     - Serializer: CreatorSerializer excluding email (public profile only)
     - Flyers list uses FlyerListSerializer with pagination (20 per page)

2. Define API response models in `pockitflyer_app/lib/features/profile/data/models/`:
   - `creator_profile_model.dart`:
     ```dart
     @freezed
     class CreatorProfileModel with _$CreatorProfileModel {
       factory CreatorProfileModel({
         required String id,
         required String displayName,
         String? bio,
         String? avatarUrl,
         required DateTime createdAt,
       }) = _CreatorProfileModel;

       factory CreatorProfileModel.fromJson(Map<String, dynamic> json) =>
           _$CreatorProfileModelFromJson(json);
     }
     ```
   - Use freezed for immutability and json_serializable for parsing
   - Run code generation: `flutter pub run build_runner build`

3. Create API client methods in `pockitflyer_app/lib/core/network/api_client.dart`:
   - Add methods:
     ```dart
     Future<CreatorProfileModel> getCreatorProfile(String creatorId);
     Future<PaginatedResponse<FlyerModel>> getCreatorFlyers(
       String creatorId,
       {int page = 1}
     );
     ```
   - Use dio for HTTP requests
   - Base URL: configured in environment or constants
   - Endpoints:
     - Profile: `GET /api/creators/$creatorId/`
     - Flyers: `GET /api/creators/$creatorId/flyers/?page=$page`
   - Error handling:
     - 404: throw CreatorNotFoundException
     - Network errors: throw NetworkException
     - Timeout: throw TimeoutException (configure dio timeout: 10 seconds)
     - Other errors: throw ApiException

4. Create custom exceptions in `pockitflyer_app/lib/core/network/exceptions.dart`:
   - Define:
     ```dart
     class CreatorNotFoundException implements Exception {
       final String message;
       CreatorNotFoundException([this.message = 'Creator not found']);
     }

     class NetworkException implements Exception {
       final String message;
       NetworkException([this.message = 'Network error']);
     }

     class TimeoutException implements Exception {
       final String message;
       TimeoutException([this.message = 'Request timed out']);
     }

     class ApiException implements Exception {
       final String message;
       final int? statusCode;
       ApiException(this.message, [this.statusCode]);
     }
     ```

5. Create Riverpod providers in `pockitflyer_app/lib/features/profile/presentation/providers/`:

   **profile_provider.dart**:
   - Provider for creator profile data:
     ```dart
     @riverpod
     Future<CreatorProfileModel> creatorProfile(
       CreatorProfileRef ref,
       String creatorId,
     ) async {
       final apiClient = ref.read(apiClientProvider);
       return apiClient.getCreatorProfile(creatorId);
     }
     ```
   - Uses FutureProvider pattern
   - Automatically caches result (Riverpod caching)
   - Exposes AsyncValue<CreatorProfileModel> to UI

   **creator_flyers_provider.dart**:
   - Provider for creator's flyers list:
     ```dart
     @riverpod
     class CreatorFlyers extends _$CreatorFlyers {
       int _currentPage = 1;
       bool _hasMore = true;
       List<FlyerModel> _flyers = [];

       @override
       Future<List<FlyerModel>> build(String creatorId) async {
         return _fetchFlyers();
       }

       Future<List<FlyerModel>> _fetchFlyers() async {
         final apiClient = ref.read(apiClientProvider);
         final response = await apiClient.getCreatorFlyers(
           creatorId,
           page: _currentPage,
         );
         _flyers = response.results;
         _hasMore = response.next != null;
         return _flyers;
       }

       Future<void> loadMore() async {
         if (!_hasMore) return;

         _currentPage++;
         final apiClient = ref.read(apiClientProvider);
         final response = await apiClient.getCreatorFlyers(
           state.value!.first.creatorId, // Extract creatorId from existing data
           page: _currentPage,
         );

         _flyers.addAll(response.results);
         _hasMore = response.next != null;
         state = AsyncValue.data(_flyers);
       }

       Future<void> refresh() async {
         _currentPage = 1;
         _hasMore = true;
         _flyers = [];
         state = await AsyncValue.guard(_fetchFlyers);
       }

       bool get hasMore => _hasMore;
     }
     ```
   - Manages pagination state
   - Provides `loadMore()` for infinite scroll
   - Provides `refresh()` for pull-to-refresh

6. Update profile page to use providers in `creator_profile_page.dart`:
   - Remove mock data imports
   - Watch providers:
     ```dart
     final profileAsync = ref.watch(creatorProfileProvider(widget.creatorId));
     final flyersAsync = ref.watch(creatorFlyersProvider(widget.creatorId));
     ```
   - Handle AsyncValue states:
     - `loading`: Show ProfileLoading widget
     - `error`: Show ProfileError widget with error type
     - `data`: Show ProfileHeader + CreatorFlyersFeed with data
   - Map exceptions to error states:
     - CreatorNotFoundException → "Creator not found" error
     - NetworkException → "Network error" error
     - TimeoutException → "Request timed out" error
     - Generic exceptions → "Something went wrong" error

7. Implement error handling in profile page:
   - Parse error from AsyncValue:
     ```dart
     profileAsync.when(
       loading: () => ProfileLoading(),
       error: (error, stack) {
         if (error is CreatorNotFoundException) {
           return ProfileError(
             type: ErrorType.notFound,
             message: 'Creator not found',
             onRetry: null, // No retry for 404
             onReturnToFeed: () => context.pop(),
           );
         } else if (error is NetworkException) {
           return ProfileError(
             type: ErrorType.network,
             message: 'Network error',
             onRetry: () => ref.refresh(creatorProfileProvider(widget.creatorId)),
           );
         } else if (error is TimeoutException) {
           return ProfileError(
             type: ErrorType.timeout,
             message: 'Request timed out',
             onRetry: () => ref.refresh(creatorProfileProvider(widget.creatorId)),
           );
         } else {
           return ProfileError(
             type: ErrorType.generic,
             message: 'Something went wrong',
             onRetry: () => ref.refresh(creatorProfileProvider(widget.creatorId)),
           );
         }
       },
       data: (profile) => /* Build UI with profile data */,
     )
     ```

8. Update CreatorFlyersFeed widget to handle pagination:
   - Add ScrollController listener to detect scroll position
   - When user scrolls to ~80% of content, call `loadMore()`:
     ```dart
     final controller = ScrollController();

     @override
     void initState() {
       super.initState();
       controller.addListener(_onScroll);
     }

     void _onScroll() {
       if (controller.position.pixels >= controller.position.maxScrollExtent * 0.8) {
         final provider = ref.read(creatorFlyersProvider(widget.creatorId).notifier);
         if (provider.hasMore) {
           provider.loadMore();
         }
       }
     }
     ```
   - Show loading indicator at bottom while loading more
   - Handle empty state: if flyers list is empty after loading, show ProfileEmptyState

9. Implement pull-to-refresh in profile page:
   - Wrap scrollable content with RefreshIndicator
   - OnRefresh callback:
     ```dart
     Future<void> _onRefresh() async {
       ref.refresh(creatorProfileProvider(widget.creatorId));
       await ref.read(creatorFlyersProvider(widget.creatorId).notifier).refresh();
     }
     ```
   - This reloads both profile and flyers data

10. Implement caching strategy:
    - Riverpod automatically caches provider results
    - Cache duration: default (until provider disposed or manually invalidated)
    - Manual cache invalidation: Use `ref.invalidate()` when needed
    - For this task: Rely on Riverpod's built-in caching (no custom cache layer needed)
    - Consider adding cache timestamp if needed in future (not required for MVP)

11. Create unit tests for API client in `test/core/network/api_client_test.dart`:
    - Test `getCreatorProfile()`:
      - Success case: returns CreatorProfileModel
      - 404 error: throws CreatorNotFoundException
      - Network error: throws NetworkException
      - Timeout: throws TimeoutException
    - Test `getCreatorFlyers()`:
      - Success case: returns paginated flyers list
      - Pagination: verify page parameter passed correctly
      - 404 error: throws CreatorNotFoundException
      - Network error: throws NetworkException
    - Use http mocking (e.g., mockito or http_mock_adapter for dio)

12. Create provider tests in `test/features/profile/presentation/providers/`:
    - `profile_provider_test.dart`:
      - Test provider returns profile data on success
      - Test provider throws exception on API error
      - Test caching behavior (multiple reads don't trigger multiple requests)
    - `creator_flyers_provider_test.dart`:
      - Test initial load returns flyers
      - Test `loadMore()` appends flyers and increments page
      - Test `loadMore()` stops when `hasMore` is false
      - Test `refresh()` resets state and reloads from page 1
      - Test error handling

13. Create integration tests in `test/features/profile/integration/`:
    - `profile_integration_test.dart`:
      - Test full profile loading flow with mocked API
      - Test error states display correctly (404, network, timeout)
      - Test retry button refetches data
      - Test empty state when creator has no flyers
      - Test pagination: scroll to bottom, verify more flyers loaded
      - Test pull-to-refresh reloads data

14. Update widget tests to use providers:
    - Update `creator_profile_page_test.dart`:
      - Use ProviderScope for testing
      - Override providers with mock data
      - Test loading state renders ProfileLoading
      - Test error states render ProfileError
      - Test success state renders profile with data
    - Example:
      ```dart
      testWidgets('shows loading state initially', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              creatorProfileProvider('id').overrideWith((_) async {
                await Future.delayed(Duration(seconds: 10)); // Never completes
                return mockProfile;
              }),
            ],
            child: MaterialApp(home: CreatorProfilePage(creatorId: 'id')),
          ),
        );

        expect(find.byType(ProfileLoading), findsOneWidget);
      });
      ```

15. Configure dio timeouts and error handling:
    - In api_client initialization:
      ```dart
      final dio = Dio(BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));

      // Add interceptor for logging (debug mode only)
      if (kDebugMode) {
        dio.interceptors.add(LogInterceptor(responseBody: true));
      }
      ```

### Acceptance Criteria
- [ ] Backend endpoints return creator profile and flyers [Test: manual API call or Postman]
- [ ] API client methods fetch data successfully [Test: unit test with real/mocked HTTP]
- [ ] Profile page shows loading state while fetching [Test: widget test with delayed provider]
- [ ] Profile page displays creator info from API [Test: integration test with mocked API]
- [ ] Profile page displays creator's flyers from API [Test: verify FlyerCard list populated with API data]
- [ ] 404 error shows "Creator not found" message [Test: mock 404 response, verify error state]
- [ ] Network error shows "Network error" with retry button [Test: mock network failure, verify error state and retry]
- [ ] Timeout error shows "Request timed out" with retry button [Test: mock timeout, verify error state]
- [ ] Retry button refetches data and updates UI [Test: trigger error, tap retry, verify new request]
- [ ] Empty state shows when creator has no flyers [Test: mock empty flyers list, verify empty state]
- [ ] Infinite scroll loads more flyers on scroll [Test: scroll to bottom, verify loadMore called]
- [ ] Pull-to-refresh reloads profile and flyers [Test: trigger refresh, verify both providers refreshed]
- [ ] Pagination stops when no more flyers [Test: load all pages, verify hasMore false, no more requests]
- [ ] Provider caching avoids redundant requests [Test: navigate away and back, verify API not called again]
- [ ] All unit tests pass with >85% coverage [Test: API client, models]
- [ ] All provider tests pass [Test: profile provider, flyers provider]
- [ ] All integration tests pass [Test: full profile loading flow]
- [ ] Widget tests updated and passing [Test: profile page with providers]

### Files to Create/Modify
- `pockitflyer_backend/flyers/views.py` - VERIFY/MODIFY: ensure CreatorViewSet with profile and flyers endpoints exists (from m01-e01-t02)
- `pockitflyer_backend/flyers/serializers.py` - VERIFY: CreatorSerializer excludes email for public profile
- `pockitflyer_app/lib/features/profile/data/models/creator_profile_model.dart` - NEW: creator profile data model
- `pockitflyer_app/lib/core/network/api_client.dart` - MODIFY: add getCreatorProfile and getCreatorFlyers methods
- `pockitflyer_app/lib/core/network/exceptions.dart` - NEW: custom exception classes
- `pockitflyer_app/lib/features/profile/presentation/providers/profile_provider.dart` - NEW: creator profile Riverpod provider
- `pockitflyer_app/lib/features/profile/presentation/providers/creator_flyers_provider.dart` - NEW: creator flyers Riverpod provider with pagination
- `pockitflyer_app/lib/features/profile/presentation/pages/creator_profile_page.dart` - MODIFY: integrate providers, remove mock data, handle states
- `pockitflyer_app/lib/features/profile/presentation/widgets/creator_flyers_feed.dart` - MODIFY: add pagination logic with ScrollController
- `pockitflyer_app/lib/features/profile/presentation/widgets/profile_error.dart` - MODIFY: add retry callbacks and error types
- `pockitflyer_app/test/core/network/api_client_test.dart` - NEW: API client unit tests
- `pockitflyer_app/test/features/profile/presentation/providers/profile_provider_test.dart` - NEW: profile provider tests
- `pockitflyer_app/test/features/profile/presentation/providers/creator_flyers_provider_test.dart` - NEW: flyers provider tests
- `pockitflyer_app/test/features/profile/integration/profile_integration_test.dart` - NEW: integration tests
- `pockitflyer_app/test/features/profile/presentation/pages/creator_profile_page_test.dart` - MODIFY: update to use providers

### Testing Requirements
- **Unit tests**: API client methods (success, errors, timeouts), model serialization/deserialization, exception classes, provider logic in isolation with mocked API client
- **Widget tests**: Profile page with provider overrides (loading state, error states, success state with data, empty state)
- **Integration tests**: Full profile loading flow with mocked HTTP responses, error handling and retry flow, pagination flow (scroll → load more → append data), pull-to-refresh flow

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter Riverpod best practices
- [ ] No console errors or warnings
- [ ] API requests include proper error handling and timeouts
- [ ] Providers correctly manage state and caching
- [ ] All loading, error, and success states work correctly in UI
- [ ] Pagination works smoothly without duplicate requests
- [ ] Pull-to-refresh reloads data correctly
- [ ] Comments added for complex state management logic
- [ ] Changes committed with reference to task ID (m01-e06-t03)
- [ ] Epic m01-e06 is complete and ready for validation

## Dependencies
- Requires: m01-e06-t01 (profile page UI), m01-e06-t02 (navigation), m01-e01-t02 (backend API endpoints), m01-e02-t03 (FlyerModel and API patterns)
- Blocks: None (completes m01-e06 epic)

## Technical Notes

### Backend Endpoint Verification
The backend endpoints should already exist from m01-e01-t02:
- `GET /api/creators/{id}/` - returns creator profile (CreatorSerializer)
- `GET /api/creators/{id}/flyers/` - returns creator's flyers (FlyerListSerializer with pagination)

If these endpoints are missing, implement them following the pattern from m01-e01-t02. DO NOT ASSUME they exist—verify by checking the code or running the backend.

### Riverpod Provider Patterns
**FutureProvider** (simple, one-time fetch):
- Use for creator profile (static data, rarely changes)
- Automatically caches result
- `ref.refresh()` to reload

**StateNotifier / AsyncNotifier** (complex state with mutations):
- Use for creator flyers (pagination, load more, refresh)
- Manages list state, pagination metadata
- Provides methods for state mutations (loadMore, refresh)

### Pagination State Management
Track three pieces of state:
1. Current page number
2. Whether more pages exist (hasMore)
3. Current list of flyers

When loading more:
- Increment page
- Fetch next page
- Append results to existing list
- Update hasMore based on response

When refreshing:
- Reset page to 1
- Clear existing list
- Fetch first page
- Update hasMore

### Caching Strategy
Riverpod caches providers by default:
- Cache key: provider + parameters (creatorId)
- Cache lifetime: until provider disposed or explicitly invalidated
- Navigating away and back: cache hit (no API call)
- Manual invalidation: `ref.invalidate(creatorProfileProvider(id))`

For MVP: Built-in caching is sufficient. No custom cache layer needed.

### Error Handling Strategy
Map HTTP status codes to exceptions:
- 404: CreatorNotFoundException (don't retry, show "not found" message)
- 408, timeout: TimeoutException (offer retry)
- 500, 502, 503: ApiException (offer retry)
- Network errors (no connection): NetworkException (offer retry)

UI maps exceptions to error states and actions (retry or return to feed).

### Dio Configuration
- Base URL: from environment or config file
- Timeouts: 10 seconds connect, 10 seconds receive
- Headers: Content-Type application/json
- Interceptors: Logging (debug mode only), error handling
- Response type: JSON

### Testing with Riverpod
Use `ProviderContainer` for unit testing providers:
```dart
test('provider returns data', () async {
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(mockApiClient),
    ],
  );

  final profile = await container.read(creatorProfileProvider('id').future);
  expect(profile.id, 'id');
});
```

Use `ProviderScope` for widget testing:
```dart
testWidgets('page shows data', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        creatorProfileProvider('id').overrideWith((_) async => mockProfile),
      ],
      child: MaterialApp(home: CreatorProfilePage(creatorId: 'id')),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text(mockProfile.displayName), findsOneWidget);
});
```

### Performance Considerations
- Use `select` to watch specific fields and avoid unnecessary rebuilds:
  ```dart
  final name = ref.watch(creatorProfileProvider(id).select((p) => p.displayName));
  ```
- Dispose ScrollController in widget's dispose method
- Debounce scroll listener to avoid excessive loadMore calls
- Use const constructors where possible

### Integration with Existing Feed
When navigating to profile from feed:
- Feed state preserved (m01-e06-t02 handles this)
- Profile loads independently
- Back navigation returns to feed without reload
- No shared state between feed and profile (both fetch independently)

### Deep Linking Support
Profile routes support deep linking (configured in m01-e06-t01):
- Direct URL: `myapp://profile/creator-123`
- go_router extracts creatorId from path
- Provider fetches data based on ID
- Works same as navigation from feed

## References
- Riverpod documentation: https://riverpod.dev/docs/introduction/getting_started
- Riverpod AsyncNotifier: https://riverpod.dev/docs/providers/notifier_provider
- Dio package: https://pub.dev/packages/dio
- freezed package: https://pub.dev/packages/freezed
- json_serializable: https://pub.dev/packages/json_serializable
- Flutter RefreshIndicator: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
- ScrollController: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
- Testing Riverpod providers: https://riverpod.dev/docs/cookbooks/testing
