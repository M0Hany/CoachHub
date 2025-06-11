class NetworkError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  NetworkError({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'NetworkError: $message (Status: $statusCode)';

  // Helper methods to check error types
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  // Factory constructors for common errors
  factory NetworkError.unauthorized([String? message]) {
    return NetworkError(
      message: message ?? 'Unauthorized access',
      statusCode: 401,
    );
  }

  factory NetworkError.noInternet() {
    return NetworkError(
      message: 'No internet connection',
      statusCode: -1,
    );
  }

  factory NetworkError.timeout() {
    return NetworkError(
      message: 'Request timeout',
      statusCode: -2,
    );
  }

  factory NetworkError.server([String? message]) {
    return NetworkError(
      message: message ?? 'Server error occurred',
      statusCode: 500,
    );
  }
} 