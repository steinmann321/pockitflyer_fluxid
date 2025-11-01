import 'package:dio/dio.dart';
import 'package:pockitflyer_app/config/api_config.dart';
import 'package:pockitflyer_app/exceptions/api_exceptions.dart';
import 'package:pockitflyer_app/models/paginated_response.dart';

class FeedApiClient {
  FeedApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.requestTimeout,
                receiveTimeout: ApiConfig.requestTimeout,
              ),
            );

  final Dio _dio;

  Future<PaginatedFeedResponse> getFeed({
    required double lat,
    required double lng,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/feed/',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.data == null) {
        throw ServerException(
          response.statusCode ?? 500,
          'Empty response from server',
        );
      }

      return PaginatedFeedResponse.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TimeoutException();
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      }

      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode ?? 500;
        final errorMessage = e.response?.data is Map
            ? (e.response?.data as Map)['error']?.toString()
            : null;
        throw ServerException(statusCode, errorMessage);
      }

      throw NetworkException('Network error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}
