/// Base exception for all API-related errors.
///
/// Follows Andrea's tip #29: Domain-driven exception handling
/// — exceptions carry structured info, not just strings.
sealed class ApiException implements Exception {
  const ApiException({this.message, this.statusCode});

  final String? message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Server returned an error response (4xx, 5xx).
class ServerException extends ApiException {
  const ServerException({
    super.message,
    super.statusCode,
    this.errors,
  });

  final Map<String, dynamic>? errors;
}

/// Request timed out.
class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Request timed out'});
}

/// No internet connection.
class NetworkException extends ApiException {
  const NetworkException({super.message = 'No internet connection'});
}

/// Token expired or unauthorized.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.statusCode = 401,
  });
}

/// Resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Not found',
    super.statusCode = 404,
  });
}

/// Catch-all for unexpected errors.
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unexpected error occurred',
    this.error,
  });

  final Object? error;
}
