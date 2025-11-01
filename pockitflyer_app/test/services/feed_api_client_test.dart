import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockitflyer_app/exceptions/api_exceptions.dart';
import 'package:pockitflyer_app/models/paginated_response.dart';
import 'package:pockitflyer_app/services/feed_api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late FeedApiClient client;

  setUp(() {
    mockDio = MockDio();
    client = FeedApiClient(dio: mockDio);
  });

  group('FeedApiClient', () {
    test('getFeed returns PaginatedFeedResponse on success', () async {
      final responseData = {
        'count': 2,
        'next': null,
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Flyer 1',
            'description': 'Description 1',
            'creator': {
              'id': 1,
              'username': 'user1',
              'profile_picture_url': null,
            },
            'images': [
              {'url': 'http://example.com/image1.jpg', 'order': 0},
            ],
            'location_address': '123 Main St',
            'latitude': 47.5,
            'longitude': 8.5,
            'distance_km': 1.2,
            'valid_from': '2024-01-01T00:00:00Z',
            'valid_until': '2024-12-31T23:59:59Z',
            'is_valid': true,
          },
          {
            'id': 2,
            'title': 'Flyer 2',
            'description': 'Description 2',
            'creator': {
              'id': 2,
              'username': 'user2',
              'profile_picture_url': null,
            },
            'images': [
              {'url': 'http://example.com/image2.jpg', 'order': 0},
            ],
            'location_address': '456 Oak Ave',
            'latitude': 47.6,
            'longitude': 8.6,
            'distance_km': 2.5,
            'valid_from': '2024-01-01T00:00:00Z',
            'valid_until': '2024-12-31T23:59:59Z',
            'is_valid': true,
          },
        ],
      };

      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      final result = await client.getFeed(lat: 47.5, lng: 8.5);

      expect(result, isA<PaginatedFeedResponse>());
      expect(result.count, 2);
      expect(result.results.length, 2);
      expect(result.results[0].title, 'Flyer 1');
      expect(result.results[1].title, 'Flyer 2');

      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/feed/',
            queryParameters: {
              'lat': 47.5,
              'lng': 8.5,
              'page': 1,
              'page_size': 20,
            },
          )).called(1);
    }, tags: ['tdd_green']);

    test('getFeed uses custom page and pageSize parameters', () async {
      final responseData = {
        'count': 0,
        'next': null,
        'previous': null,
        'results': <Map<String, dynamic>>[],
      };

      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      await client.getFeed(lat: 47.5, lng: 8.5, page: 3, pageSize: 10);

      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/feed/',
            queryParameters: {
              'lat': 47.5,
              'lng': 8.5,
              'page': 3,
              'page_size': 10,
            },
          )).called(1);
    }, tags: ['tdd_green']);

    test('getFeed throws TimeoutException on timeout', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<TimeoutException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws NetworkException on connection error', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<NetworkException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws ServerException on 4xx error', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'error': 'Bad request'},
            requestOptions: RequestOptions(path: '/api/feed/'),
          ),
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(
          isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            400,
          ),
        ),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws ServerException on 5xx error', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'error': 'Internal server error'},
            requestOptions: RequestOptions(path: '/api/feed/'),
          ),
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(
          isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws NetworkException on unknown DioException', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<NetworkException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws TimeoutException on receiveTimeout', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<TimeoutException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws TimeoutException on sendTimeout', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<TimeoutException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws ServerException when response data is null', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Empty response from server'),
        ),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws ServerException with default message when error field missing', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'Not found'},
            requestOptions: RequestOptions(path: '/api/feed/'),
          ),
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<ServerException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws ServerException when response data is not a Map', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: 'Internal Server Error',
            requestOptions: RequestOptions(path: '/api/feed/'),
          ),
          requestOptions: RequestOptions(path: '/api/feed/'),
        ),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<ServerException>()),
      );
    }, tags: ['tdd_green']);

    test('getFeed throws ApiException on unexpected error', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        Exception('Unexpected error'),
      );

      expect(
        () => client.getFeed(lat: 47.5, lng: 8.5),
        throwsA(isA<ApiException>()),
      );
    }, tags: ['tdd_green']);
  });
}
