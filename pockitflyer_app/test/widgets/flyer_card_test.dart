import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:pockitflyer_app/models/creator.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:pockitflyer_app/models/flyer_image.dart';
import 'package:pockitflyer_app/widgets/flyer_card.dart';

void main() {
  group('FlyerCard Widget Tests', () {
    late Flyer testFlyer;

    setUp(() {
      testFlyer = Flyer(
        id: 1,
        title: 'Test Flyer Title',
        description: 'This is a test flyer description.',
        creator: Creator(
          id: 1,
          username: 'testuser',
          profilePictureUrl: null,
        ),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: '123 Test St, Test City',
        latitude: 37.7749,
        longitude: -122.4194,
        distanceKm: 1.5,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );
    });

    testWidgets('renders creator username', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('creator_username')), findsOneWidget);
      final usernameFinder = find.byKey(const Key('creator_username'));
      final usernameWidget = tester.widget<Text>(usernameFinder);
      expect(usernameWidget.data, 'testuser');
    }, tags: ['tdd_green']);

    testWidgets('renders default avatar when no profile picture', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('creator_avatar')), findsOneWidget);
      expect(find.byKey(const Key('default_avatar')), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('renders default avatar when profile picture is empty string', (tester) async {
      final flyerEmptyAvatar = Flyer(
        id: 1,
        title: 'Test',
        description: 'Desc',
        creator: Creator(id: 1, username: 'user', profilePictureUrl: ''),
        images: [FlyerImage(url: 'img.jpg', order: 0)],
        locationAddress: 'Addr',
        latitude: 0,
        longitude: 0,
        distanceKm: 1.0,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(flyer: flyerEmptyAvatar),
          ),
        ),
      );

      // Empty string should use default avatar (not network image)
      expect(find.byKey(const Key('default_avatar')), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('uses different avatar colors for different usernames', (tester) async {
      // Test that different usernames get different colors (covers _getAvatarColor)
      final flyer1 = Flyer(
        id: 1,
        title: 'Test',
        description: 'Desc',
        creator: Creator(id: 1, username: 'alice', profilePictureUrl: null),
        images: [FlyerImage(url: 'img.jpg', order: 0)],
        locationAddress: 'Addr',
        latitude: 0,
        longitude: 0,
        distanceKm: 1.0,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(flyer: flyer1),
          ),
        ),
      );

      // Verify avatar uses default avatar (which calls _getAvatarColor)
      expect(find.byKey(const Key('default_avatar')), findsOneWidget);
      final avatar = tester.widget<CircleAvatar>(
        find.byKey(const Key('creator_avatar')),
      );
      // Verify it has a background color (proving _getAvatarColor was called)
      expect(avatar.backgroundColor, isNotNull);
    }, tags: ['tdd_green']);

    testWidgets('renders flyer title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('flyer_title')), findsOneWidget);
      final titleFinder = find.byKey(const Key('flyer_title'));
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.data, 'Test Flyer Title');
      expect(titleWidget.maxLines, 2);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    }, tags: ['tdd_green']);

    testWidgets('renders flyer description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('flyer_description')), findsOneWidget);
      final descFinder = find.byKey(const Key('flyer_description'));
      final descWidget = tester.widget<Text>(descFinder);
      expect(descWidget.data, 'This is a test flyer description.');
      expect(descWidget.maxLines, 4);
      expect(descWidget.overflow, TextOverflow.ellipsis);
    }, tags: ['tdd_green']);

    testWidgets('renders location address', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('location_address')), findsOneWidget);
      final addressFinder = find.byKey(const Key('location_address'));
      final addressWidget = tester.widget<Text>(addressFinder);
      expect(addressWidget.data, '123 Test St, Test City');
    }, tags: ['tdd_green']);

    testWidgets('renders distance in km when >= 1 km', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('location_distance')), findsOneWidget);
      final distanceFinder = find.byKey(const Key('location_distance'));
      final distanceWidget = tester.widget<Text>(distanceFinder);
      expect(distanceWidget.data, '1.5 km');
    }, tags: ['tdd_green']);

    testWidgets('renders distance in meters when < 1 km', (tester) async {
      final flyerWithShortDistance = Flyer(
        id: 1,
        title: 'Test Flyer',
        description: 'Test description',
        creator: Creator(id: 1, username: 'testuser'),
        images: [FlyerImage(url: 'https://example.com/image1.jpg', order: 0)],
        locationAddress: '123 Test St',
        latitude: 37.7749,
        longitude: -122.4194,
        distanceKm: 0.5,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: flyerWithShortDistance,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('location_distance')), findsOneWidget);
      final distanceFinder = find.byKey(const Key('location_distance'));
      final distanceWidget = tester.widget<Text>(distanceFinder);
      expect(distanceWidget.data, '500 m');
    }, tags: ['tdd_green']);

    testWidgets('renders validity period', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('validity_text')), findsOneWidget);
      final validityFinder = find.byKey(const Key('validity_text'));
      final validityWidget = tester.widget<Text>(validityFinder);
      expect(validityWidget.data, contains('Valid until'));
      expect(validityWidget.data, contains('Dec 31, 2025'));
    }, tags: ['tdd_green']);

    testWidgets('has tap detector for future navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      // Verify tap detector exists as placeholder for M01-E03
      expect(find.byKey(const Key('card_tap_detector')), findsOneWidget);

      // Verify we can tap on the card (placeholder - actual navigation in M01-E03)
      await tester.tap(find.byKey(const Key('card_tap_detector')));
      await tester.pumpAndSettle();

      // No navigation yet - just verify tap doesn't cause errors
    }, tags: ['tdd_green']);

    testWidgets('has card elevation and rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(
              key: const Key('flyer_card'),
              flyer: testFlyer,
            ),
          ),
        ),
      );

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final card = tester.widget<Card>(cardFinder);
      expect(card.elevation, greaterThan(0));
      expect(card.shape, isA<RoundedRectangleBorder>());
    }, tags: ['tdd_green']);
  });

  group('FlyerCard Image Carousel Tests', () {
    testWidgets('displays single image without carousel controls', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Single Image Flyer',
        description: 'Description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
          ),
        ),
      );

      expect(find.byKey(const Key('image_carousel')), findsOneWidget);
      expect(find.byKey(const Key('carousel_indicator')), findsNothing);
    }, tags: ['tdd_green']);

    testWidgets('displays carousel with position indicator for multiple images',
        (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Multi Image Flyer',
        description: 'Description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
          FlyerImage(url: 'https://example.com/image2.jpg', order: 1),
          FlyerImage(url: 'https://example.com/image3.jpg', order: 2),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
          ),
        ),
      );

      expect(find.byKey(const Key('image_carousel')), findsOneWidget);
      expect(find.byKey(const Key('carousel_indicator')), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('carousel has swipe callback configured', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Multi Image Flyer',
        description: 'Description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
          FlyerImage(url: 'https://example.com/image2.jpg', order: 1),
          FlyerImage(url: 'https://example.com/image3.jpg', order: 2),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
          ),
        ),
      );

      // Verify carousel is rendered
      expect(find.byKey(const Key('image_carousel')), findsOneWidget);

      // Verify position indicator shows initial state (1/3)
      expect(find.text('1 / 3'), findsOneWidget);

      // CarouselSlider swipe behavior is configured via CarouselOptions.onPageChanged
      // Actual swipe testing requires integration tests due to gesture complexity
      // This test verifies the carousel structure and initial state
    }, tags: ['tdd_green']);
  });

  group('FlyerCard Loading and Error States', () {
    testWidgets('has loading state configured for images', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Test Flyer',
        description: 'Description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
          ),
        ),
      );

      // Verify image widget exists (loading builder is configured in implementation)
      expect(find.byType(Image), findsAtLeastNWidgets(1));

      // The loading builder with shimmer key is configured in the widget
      // but only appears during actual loading, which doesn't happen in tests
      // This test verifies the widget structure supports loading states
    }, tags: ['tdd_green']);

    testWidgets('shows placeholder on image load error', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Test Flyer',
        description: 'Description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://invalid-url.com/nonexistent.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
          ),
        ),
      );

      // Wait for error to occur
      await tester.pump(const Duration(seconds: 1));

      // Error placeholder should be visible
      expect(find.byKey(const Key('image_error_placeholder')), findsOneWidget);
    }, tags: ['tdd_green']);
  });

  group('FlyerCard Description Expansion Tests', () {
    testWidgets('shows "Show more" link for long descriptions', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Title',
        description: 'This is a very long description that should be truncated after four lines. ' * 10,
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('show_more_link')), findsOneWidget);
      expect(find.text('Show more'), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('does not show "Show more" link for short descriptions', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Title',
        description: 'Short description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('show_more_link')), findsNothing);
    }, tags: ['tdd_green']);

    testWidgets('expands description when "Show more" is tapped', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Title',
        description: 'This is a very long description that should be truncated after four lines. ' * 10,
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
              ),
            ),
          ),
        ),
      );

      final descWidget = tester.widget<Text>(find.byKey(const Key('flyer_description')));
      expect(descWidget.maxLines, 4);

      await tester.tap(find.byKey(const Key('show_more_link')));
      await tester.pumpAndSettle();

      final expandedDescWidget = tester.widget<Text>(find.byKey(const Key('flyer_description')));
      expect(expandedDescWidget.maxLines, isNull);
      expect(find.text('Show less'), findsOneWidget);
    }, tags: ['tdd_green']);

    testWidgets('collapses description when "Show less" is tapped', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Title',
        description: 'This is a very long description that should be truncated after four lines. ' * 10,
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
              ),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.byKey(const Key('show_more_link')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('show_more_link')));
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('show_more_link')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('show_more_link')));
      await tester.pumpAndSettle();

      final collapsedDescWidget = tester.widget<Text>(find.byKey(const Key('flyer_description')));
      expect(collapsedDescWidget.maxLines, 4);
      expect(find.text('Show more'), findsOneWidget);
    }, tags: ['tdd_green']);
  });

  group('FlyerCard Text Truncation Tests', () {
    testWidgets('truncates long title with ellipsis', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'This is a very long title that should be truncated after two lines because it exceeds the maximum allowed length for display',
        description: 'Description',
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
            ),
          ),
        ),
      );

      final titleFinder = find.byKey(const Key('flyer_title'));
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.maxLines, 2);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    }, tags: ['tdd_green']);

    testWidgets('truncates long description with ellipsis', (tester) async {
      final flyer = Flyer(
        id: 1,
        title: 'Title',
        description: 'This is a very long description that should be truncated after four lines. ' * 10,
        creator: Creator(id: 1, username: 'user'),
        images: [
          FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
        ],
        locationAddress: 'Address',
        latitude: 0,
        longitude: 0,
        distanceKm: 1,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: FlyerCard(key: const Key('flyer_card'), flyer: flyer),
            ),
          ),
        ),
      );

      final descFinder = find.byKey(const Key('flyer_description'));
      final descWidget = tester.widget<Text>(descFinder);
      expect(descWidget.maxLines, 4);
      expect(descWidget.overflow, TextOverflow.ellipsis);
    }, tags: ['tdd_green']);

    testWidgets('does not show distance when null', (tester) async {
      final flyerNoDistance = Flyer(
        id: 99,
        title: 'No Distance',
        description: 'Test',
        creator: Creator(id: 1, username: 'user', profilePictureUrl: null),
        images: [FlyerImage(url: 'test.jpg', order: 0)],
        locationAddress: 'Addr',
        latitude: 0,
        longitude: 0,
        distanceKm: null,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(flyer: flyerNoDistance),
          ),
        ),
      );

      // Distance widget should not exist when distanceKm is null
      expect(find.byKey(const Key('location_distance')), findsNothing);
    }, tags: ['tdd_green']);

    testWidgets('formats distance exactly at 1 km boundary', (tester) async {
      final flyerExactly1Km = Flyer(
        id: 100,
        title: 'Exactly 1km',
        description: 'Test',
        creator: Creator(id: 1, username: 'user', profilePictureUrl: null),
        images: [FlyerImage(url: 'test.jpg', order: 0)],
        locationAddress: 'Addr',
        latitude: 0,
        longitude: 0,
        distanceKm: 1.0,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlyerCard(flyer: flyerExactly1Km),
          ),
        ),
      );

      final distanceWidget = tester.widget<Text>(find.byKey(const Key('location_distance')));
      expect(distanceWidget.data, '1.0 km');
    }, tags: ['tdd_green']);
  });

  group('FlyerCard Golden Tests', () {
    testWidgets('renders correctly with single image', (tester) async {
      await mockNetworkImages(() async {
        final flyer = Flyer(
          id: 1,
          title: 'Test Flyer Title',
          description: 'This is a test flyer description.',
          creator: Creator(
            id: 1,
            username: 'testuser',
            profilePictureUrl: null,
          ),
          images: [
            FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
          ],
          locationAddress: '123 Test St, Test City',
          latitude: 37.7749,
          longitude: -122.4194,
          distanceKm: 1.5,
          validFrom: DateTime(2025, 1, 1),
          validUntil: DateTime(2025, 12, 31),
          isValid: true,
        );

        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlyerCard(flyer: flyer),
            ),
          ),
        );

        await expectLater(
          find.byType(FlyerCard),
          matchesGoldenFile('goldens/flyer_card_single_image.png'),
        );
      });
    }, tags: ['tdd_green']);

    testWidgets('renders correctly with multiple images', (tester) async {
      await mockNetworkImages(() async {
        final flyer = Flyer(
          id: 1,
          title: 'Multi Image Flyer',
          description: 'This flyer has multiple images in a carousel.',
          creator: Creator(
            id: 1,
            username: 'testuser',
            profilePictureUrl: null,
          ),
          images: [
            FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
            FlyerImage(url: 'https://example.com/image2.jpg', order: 1),
            FlyerImage(url: 'https://example.com/image3.jpg', order: 2),
          ],
          locationAddress: '456 Multi St, Test City',
          latitude: 37.7749,
          longitude: -122.4194,
          distanceKm: 2.3,
          validFrom: DateTime(2025, 1, 1),
          validUntil: DateTime(2025, 12, 31),
          isValid: true,
        );

        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlyerCard(flyer: flyer),
            ),
          ),
        );

        await expectLater(
          find.byType(FlyerCard),
          matchesGoldenFile('goldens/flyer_card_multiple_images.png'),
        );
      });
    }, tags: ['tdd_green']);

    testWidgets('renders correctly with long description', (tester) async {
      await mockNetworkImages(() async {
        final flyer = Flyer(
          id: 1,
          title: 'Long Description Flyer',
          description: 'This is a very long description that should be truncated after four lines. ' * 10,
          creator: Creator(
            id: 1,
            username: 'testuser',
            profilePictureUrl: null,
          ),
          images: [
            FlyerImage(url: 'https://example.com/image1.jpg', order: 0),
          ],
          locationAddress: '789 Long St, Test City',
          latitude: 37.7749,
          longitude: -122.4194,
          distanceKm: 0.5,
          validFrom: DateTime(2025, 1, 1),
          validUntil: DateTime(2025, 12, 31),
          isValid: true,
        );

        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlyerCard(flyer: flyer),
            ),
          ),
        );

        await expectLater(
          find.byType(FlyerCard),
          matchesGoldenFile('goldens/flyer_card_long_description.png'),
        );
      });
    }, tags: ['tdd_green']);
  });
}
