import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('baseUrl returns localhost in debug mode', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl, startsWith('http'));
    }, tags: ['tdd_green']);

    test('requestTimeout is 10 seconds', () {
      expect(ApiConfig.requestTimeout, equals(const Duration(seconds: 10)));
    }, tags: ['tdd_green']);
  });
}
