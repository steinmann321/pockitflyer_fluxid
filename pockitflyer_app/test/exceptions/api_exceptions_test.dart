import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/exceptions/api_exceptions.dart';

void main() {
  group('ApiException', () {
    test('creates exception with message', () {
      final exception = ApiException('Test error');
      expect(exception.message, equals('Test error'));
    }, tags: ['tdd_green']);

    test('toString returns formatted message', () {
      final exception = ApiException('Test error');
      expect(exception.toString(), equals('ApiException: Test error'));
    }, tags: ['tdd_green']);
  });

  group('NetworkException', () {
    test('creates exception with custom message', () {
      final exception = NetworkException('Connection failed');
      expect(exception.message, equals('Connection failed'));
      expect(exception, isA<ApiException>());
    }, tags: ['tdd_green']);

    test('creates exception with default message', () {
      final exception = NetworkException();
      expect(exception.message, equals('Network error occurred'));
    }, tags: ['tdd_green']);
  });

  group('TimeoutException', () {
    test('creates exception with custom message', () {
      final exception = TimeoutException('Slow connection');
      expect(exception.message, equals('Slow connection'));
      expect(exception, isA<ApiException>());
    }, tags: ['tdd_green']);

    test('creates exception with default message', () {
      final exception = TimeoutException();
      expect(exception.message, equals('Request timeout'));
    }, tags: ['tdd_green']);
  });

  group('ServerException', () {
    test('creates exception with status code and custom message', () {
      final exception = ServerException(404, 'Not found');
      expect(exception.statusCode, equals(404));
      expect(exception.message, equals('Not found'));
      expect(exception, isA<ApiException>());
    }, tags: ['tdd_green']);

    test('creates exception with status code and default message', () {
      final exception = ServerException(500);
      expect(exception.statusCode, equals(500));
      expect(exception.message, equals('Server error (status: 500)'));
    }, tags: ['tdd_green']);
  });
}
