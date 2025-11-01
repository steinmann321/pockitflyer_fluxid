import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockitflyer_app/exceptions/api_exceptions.dart';
import 'package:pockitflyer_app/models/creator.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:pockitflyer_app/models/flyer_image.dart';
import 'package:pockitflyer_app/models/paginated_response.dart';
import 'package:pockitflyer_app/providers/feed_provider.dart';
import 'package:pockitflyer_app/services/feed_api_client.dart';
import 'package:pockitflyer_app/services/location_service.dart';

class MockFeedApiClient extends Mock implements FeedApiClient {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  group('FeedProvider', () {
    late FeedApiClient mockFeedApiClient;
    late LocationService mockLocationService;
    late FeedProvider feedProvider;

    setUp(() {
      mockFeedApiClient = MockFeedApiClient();
      mockLocationService = MockLocationService();
      feedProvider = FeedProvider(
        feedApiClient: mockFeedApiClient,
        locationService: mockLocationService,
      );
    });

    Flyer createTestFlyer({int id = 1}) {
      return Flyer(
        id: id,
        title: 'Test Flyer $id',
        description: 'Description $id',
        creator: Creator(
          id: 1,
          username: 'testuser',
          profilePictureUrl: null,
        ),
        images: [
          FlyerImage(
            url: 'https://example.com/image.jpg',
            order: 0,
          ),
        ],
        locationAddress: '123 Test St',
        latitude: 37.7749,
        longitude: -122.4194,
        distanceKm: 1.5,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );
    }

    group('initial state', () {
      test('should have initial status', () {
        expect(feedProvider.status, FeedStatus.initial);
        expect(feedProvider.flyers, isEmpty);
        expect(feedProvider.errorMessage, isNull);
        expect(feedProvider.hasMore, isTrue);
      }, tags: ['tdd_green']);
    });

    group('loadFeed', () {
      test('should load feed successfully', () async {
        final testFlyers = [createTestFlyer(id: 1), createTestFlyer(id: 2)];
        final mockResponse = PaginatedFeedResponse(
          count: 2,
          results: testFlyers,
          next: null,
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final statusUpdates = <FeedStatus>[];
        feedProvider.addListener(() {
          statusUpdates.add(feedProvider.status);
        });

        await feedProvider.loadFeed();

        expect(statusUpdates, [FeedStatus.loading, FeedStatus.loaded]);
        expect(feedProvider.status, FeedStatus.loaded);
        expect(feedProvider.flyers, testFlyers);
        expect(feedProvider.errorMessage, isNull);
        expect(feedProvider.hasMore, isFalse);

        verify(
          () => mockFeedApiClient.getFeed(
            lat: 37.7749,
            lng: -122.4194,
            page: 1,
          ),
        ).called(1);
      }, tags: ['tdd_green']);

      test('should set empty status when no flyers returned', () async {
        final mockResponse = PaginatedFeedResponse(
          count: 0,
          results: [],
          next: null,
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await feedProvider.loadFeed();

        expect(feedProvider.status, FeedStatus.empty);
        expect(feedProvider.flyers, isEmpty);
      }, tags: ['tdd_green']);

      test('should set error status when API call fails', () async {
        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenThrow(NetworkException('No internet connection'));

        await feedProvider.loadFeed();

        expect(feedProvider.status, FeedStatus.error);
        expect(feedProvider.errorMessage, contains('No internet connection'));
        expect(feedProvider.flyers, isEmpty);
      }, tags: ['tdd_green']);

      test('should not load if already loading', () async {
        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => PaginatedFeedResponse(
              count: 1,
              results: [createTestFlyer()],
              next: null,
              previous: null,
            ),
          ),
        );

        // Start first load (don't await)
        final firstLoad = feedProvider.loadFeed();

        // Try to load again while first is in progress
        await feedProvider.loadFeed();

        // Wait for first load to complete
        await firstLoad;

        // Should only call once
        verify(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).called(1);
      }, tags: ['tdd_green']);

      test('should set hasMore to true when next page exists', () async {
        final mockResponse = PaginatedFeedResponse(
          count: 50,
          results: [createTestFlyer()],
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await feedProvider.loadFeed();

        expect(feedProvider.hasMore, isTrue);
      }, tags: ['tdd_green']);
    });

    group('refresh', () {
      test('should reset page and reload feed', () async {
        final mockResponse = PaginatedFeedResponse(
          count: 1,
          results: [createTestFlyer()],
          next: null,
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await feedProvider.refresh();

        expect(feedProvider.status, FeedStatus.loaded);
        verify(
          () => mockFeedApiClient.getFeed(
            lat: 37.7749,
            lng: -122.4194,
            page: 1,
          ),
        ).called(1);
      }, tags: ['tdd_green']);
    });

    group('loadMore', () {
      test('should load next page and append results', () async {
        final firstPageFlyers = [createTestFlyer(id: 1)];
        final secondPageFlyers = [createTestFlyer(id: 2)];

        final firstPageResponse = PaginatedFeedResponse(
          count: 2,
          results: firstPageFlyers,
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        );

        final secondPageResponse = PaginatedFeedResponse(
          count: 2,
          results: secondPageFlyers,
          next: null,
          previous: 'http://example.com/api/feed/?page=1',
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 1,
          ),
        ).thenAnswer((_) async => firstPageResponse);

        // Load first page
        await feedProvider.loadFeed();
        expect(feedProvider.flyers.length, 1);

        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 2,
          ),
        ).thenAnswer((_) async => secondPageResponse);

        final statusUpdates = <FeedStatus>[];
        feedProvider.addListener(() {
          statusUpdates.add(feedProvider.status);
        });

        // Load second page
        await feedProvider.loadMore();

        expect(
          statusUpdates,
          [FeedStatus.loadingMore, FeedStatus.loaded],
        );
        expect(feedProvider.flyers.length, 2);
        expect(feedProvider.flyers[0].id, 1);
        expect(feedProvider.flyers[1].id, 2);
        expect(feedProvider.hasMore, isFalse);
      }, tags: ['tdd_green']);

      test('should not load more when hasMore is false', () async {
        final mockResponse = PaginatedFeedResponse(
          count: 1,
          results: [createTestFlyer()],
          next: null,
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Load first page
        await feedProvider.loadFeed();
        expect(feedProvider.hasMore, isFalse);

        // Try to load more
        await feedProvider.loadMore();

        // Should only call once (for initial load)
        verify(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
          ),
        ).called(1);
      }, tags: ['tdd_green']);

      test('should not load more when already loading more', () async {
        final firstPageResponse = PaginatedFeedResponse(
          count: 2,
          results: [createTestFlyer(id: 1)],
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 1,
          ),
        ).thenAnswer((_) async => firstPageResponse);

        await feedProvider.loadFeed();

        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 2,
          ),
        ).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => PaginatedFeedResponse(
              count: 2,
              results: [createTestFlyer(id: 2)],
              next: null,
              previous: null,
            ),
          ),
        );

        // Start loading more (don't await)
        final firstLoadMore = feedProvider.loadMore();

        // Try to load more again
        await feedProvider.loadMore();

        // Wait for first to complete
        await firstLoadMore;

        // Should only call page 2 once
        verify(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 2,
          ),
        ).called(1);
      }, tags: ['tdd_green']);

      test('should set error status when loadMore fails', () async {
        final firstPageResponse = PaginatedFeedResponse(
          count: 2,
          results: [createTestFlyer(id: 1)],
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        );

        when(() => mockLocationService.getLocation()).thenAnswer(
          (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
        );
        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 1,
          ),
        ).thenAnswer((_) async => firstPageResponse);

        await feedProvider.loadFeed();

        when(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 2,
          ),
        ).thenThrow(NetworkException('Connection lost'));

        await feedProvider.loadMore();

        expect(feedProvider.status, FeedStatus.error);
        expect(feedProvider.errorMessage, contains('Connection lost'));
        expect(feedProvider.flyers.length, 1); // Original flyers still there
      }, tags: ['tdd_green']);
    });
  });
}
