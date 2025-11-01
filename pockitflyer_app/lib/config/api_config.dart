import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return 'http://localhost:8000';
    }
    // Production URL will be configured later
    return 'https://api.pockitflyer.com';
  }

  static const Duration requestTimeout = Duration(seconds: 10);
}
