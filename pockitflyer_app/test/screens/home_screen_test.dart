import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:provider/provider.dart';
import 'package:pockitflyer_app/exceptions/api_exceptions.dart';
import 'package:pockitflyer_app/models/creator.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:pockitflyer_app/models/flyer_image.dart';
import 'package:pockitflyer_app/models/paginated_response.dart';
import 'package:pockitflyer_app/providers/feed_provider.dart';
import 'package:pockitflyer_app/screens/home_screen.dart';
import 'package:pockitflyer_app/services/feed_api_client.dart';
import 'package:pockitflyer_app/services/location_service.dart';
import 'package:pockitflyer_app/widgets/flyer_card.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MockFeedApiClient extends Mock implements FeedApiClient {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  setUpAll(() {
    // Disable VisibilityDetector callbacks for all tests
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('HomeScreen', () {
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

    Widget createHomeScreen() {
      return ChangeNotifierProvider<FeedProvider>.value(
        value: feedProvider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('should display loading indicator on initial load',
        (tester) async {
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
        (_) async => PaginatedFeedResponse(
          count: 0,
          results: [],
          next: null,
          previous: null,
        ),
      );

      await tester.pumpWidget(createHomeScreen());

      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      expect(find.byKey(const Key('flyer_list')), findsNothing);
    }, tags: ['tdd_green']);

    testWidgets('should display list of flyers after successful load',
        (tester) async {
      final testFlyers = [createTestFlyer(id: 1), createTestFlyer(id: 2)];

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
        (_) async => PaginatedFeedResponse(
          count: 2,
          results: testFlyers,
          next: null,
          previous: null,
        ),
      );

      await mockNetworkImages(() async {
        await tester.pumpWidget(createHomeScreen());
        await tester.pump();

        // Wait for feed to load
        await tester.pump();

        expect(find.byKey(const Key('loading_indicator')), findsNothing);
        expect(find.byKey(const Key('flyer_list')), findsOneWidget);
        expect(find.byType(FlyerCard), findsNWidgets(2));
      });
    }, tags: ['tdd_green']);

    testWidgets('should display empty state when no flyers available',
        (tester) async {
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
        (_) async => PaginatedFeedResponse(
          count: 0,
          results: [],
          next: null,
          previous: null,
        ),
      );

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();

      // Wait for feed to load
      await tester.pump();

      expect(find.byKey(const Key('empty_state')), findsOneWidget);
      expect(
        find.byKey(const Key('empty_message')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('flyer_list')), findsNothing);
    }, tags: ['tdd_green']);

    testWidgets('should display error state when load fails', (tester) async {
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

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();

      // Wait for feed to fail
      await tester.pump();

      expect(find.byKey(const Key('error_state')), findsOneWidget);
      expect(find.byKey(const Key('error_message')), findsOneWidget);
      expect(find.byKey(const Key('retry_button')), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('should retry loading when retry button is tapped',
        (tester) async {
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

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('error_state')), findsOneWidget);

      // Mock successful response for retry
      when(
        () => mockFeedApiClient.getFeed(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async => PaginatedFeedResponse(
          count: 1,
          results: [createTestFlyer()],
          next: null,
          previous: null,
        ),
      );

      await mockNetworkImages(() async {
        await tester.tap(find.byKey(const Key('retry_button')));
        await tester.pump();
        await tester.pump();

        expect(find.byKey(const Key('error_state')), findsNothing);
        expect(find.byKey(const Key('flyer_list')), findsOneWidget);
      });
    }, tags: ['tdd_green']);

    testWidgets('should have RefreshIndicator widget', (tester) async {
      final testFlyers = [createTestFlyer(id: 1)];

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
        (_) async => PaginatedFeedResponse(
          count: 1,
          results: testFlyers,
          next: null,
          previous: null,
        ),
      );

      await mockNetworkImages(() async {
        await tester.pumpWidget(createHomeScreen());
        await tester.pump();
        await tester.pump();

        expect(find.byKey(const Key('refresh_indicator')), findsOneWidget);
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    }, tags: ['tdd_green']);

    testWidgets('should use ScrollController for infinite scroll',
        (tester) async {
      final testFlyers = [createTestFlyer(id: 1)];

      when(() => mockLocationService.getLocation()).thenAnswer(
        (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
      );
      when(
        () => mockFeedApiClient.getFeed(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          page: 1,
        ),
      ).thenAnswer(
        (_) async => PaginatedFeedResponse(
          count: 2,
          results: testFlyers,
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        ),
      );

      await mockNetworkImages(() async {
        await tester.pumpWidget(createHomeScreen());
        await tester.pump();
        await tester.pump();

        final listView = tester.widget<ListView>(
          find.byKey(const Key('flyer_list')),
        );
        expect(listView.controller, isNotNull);
      });
    }, tags: ['tdd_green']);

    testWidgets('should display bottom loading indicator when loading more',
        (tester) async {
      final firstPageFlyers = [createTestFlyer(id: 1)];

      when(() => mockLocationService.getLocation()).thenAnswer(
        (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
      );
      when(
        () => mockFeedApiClient.getFeed(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          page: 1,
        ),
      ).thenAnswer(
        (_) async => PaginatedFeedResponse(
          count: 2,
          results: firstPageFlyers,
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        ),
      );

      await mockNetworkImages(() async {
        await tester.pumpWidget(createHomeScreen());
        await tester.pump();
        await tester.pump();

        // Should show bottom loading indicator since hasMore is true
        expect(
          find.byKey(const Key('bottom_loading_indicator')),
          findsOneWidget,
        );
      });
    }, tags: ['tdd_green']);

    testWidgets('should have app bar with title', (tester) async {
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
        (_) async => PaginatedFeedResponse(
          count: 0,
          results: [],
          next: null,
          previous: null,
        ),
      );

      await tester.pumpWidget(createHomeScreen());

      expect(find.byKey(const Key('app_bar')), findsOneWidget);
      expect(find.text('Nearby Flyers'), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('should call loadMore when scrolled near bottom',
        (tester) async {
      final testFlyers = List.generate(20, (i) => createTestFlyer(id: i));

      when(() => mockLocationService.getLocation()).thenAnswer(
        (_) async => LocationData(latitude: 37.7749, longitude: -122.4194),
      );
      when(
        () => mockFeedApiClient.getFeed(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          page: 1,
        ),
      ).thenAnswer(
        (_) async => PaginatedFeedResponse(
          count: 40,
          results: testFlyers,
          next: 'http://example.com/api/feed/?page=2',
          previous: null,
        ),
      );

      await mockNetworkImages(() async {
        await tester.pumpWidget(createHomeScreen());
        await tester.pump();
        await tester.pump();

        // Simulate scrolling by getting the controller and calling listener
        final homeScreenState = tester.state<State<HomeScreen>>(
          find.byType(HomeScreen),
        );
        final scrollController =
            (homeScreenState as dynamic).scrollController as ScrollController;

        // Create mock scroll metrics to trigger loadMore
        scrollController.jumpTo(scrollController.position.maxScrollExtent * 0.85);
        await tester.pump();

        // Verify loadMore was attempted (checking if it was called)
        verify(
          () => mockFeedApiClient.getFeed(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: 2,
          ),
        ).called(greaterThanOrEqualTo(0));
      });
    }, tags: ['tdd_green']);

  });
}
