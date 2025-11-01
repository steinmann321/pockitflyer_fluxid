class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network error occurred'])
      : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timeout']) : super(message);
}

class ServerException extends ApiException {
  ServerException(this.statusCode, [String? message])
      : super(message ?? 'Server error (status: $statusCode)');

  final int statusCode;
}
