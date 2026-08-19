import 'dart:io';

import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import '../errors/api_exception.dart';

/// Maps [DioException] to domain [ApiException].
///
/// Follows Andrea's tip #29: Domain-driven exception handling
/// — the presentation layer never sees raw Dio errors.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    // Already wrapped (e.g., by AuthInterceptor)
    if (err.error is ApiException) {
      return err.error as ApiException;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(err.response);

      case DioExceptionType.cancel:
        return const UnknownApiException(message: 'Request cancelled');

      default:
        if (err.error is SocketException) {
          return const NetworkException();
        }
        AppLogger.e(
          'Unhandled DioException',
          error: err,
          stackTrace: err.stackTrace,
        );
        return UnknownApiException(
          message: err.message,
          error: err.error,
        );
    }
  }

  ApiException _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    final message = data is Map<String, dynamic>
        ? (data['message'] as String? ?? data['error'] as String?)
        : null;

    if (statusCode == 401) {
      return UnauthorizedException(message: message);
    }
    if (statusCode == 404) {
      return NotFoundException(message: message);
    }
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return ServerException(
        statusCode: statusCode,
        message: message ?? 'Server error',
      );
    }
    return ServerException(
      statusCode: statusCode,
      message: message ?? 'Request failed',
    );
  }
}
