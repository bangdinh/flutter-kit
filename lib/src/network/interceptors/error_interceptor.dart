import 'dart:io';

import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import '../errors/api_exception.dart';
import '../errors/problem_detail.dart';

/// Header a gokit service echoes the correlation id on when the problem body
/// carries none (set by the gateway / `X-Request-Id` middleware).
const _requestIdHeader = 'x-request-id';

/// Translates transport failures into the kit's [ApiException] contract.
///
/// A gokit error response is RFC 9457 `application/problem+json`; this is where
/// it is parsed, so nothing above ever touches `DioException` or a raw body.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: _mapException(err),
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    // Already classified upstream (AuthInterceptor rejects a 401 itself).
    if (err.error is ApiException) return err.error! as ApiException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapResponse(err.response);

      case DioExceptionType.cancel:
        return const UnknownApiException(message: 'Request cancelled');

      default:
        if (err.error is SocketException) return const NetworkException();
        AppLogger.e(
          'Unhandled DioException',
          error: err,
          stackTrace: err.stackTrace,
        );
        return UnknownApiException(message: err.message, error: err.error);
    }
  }

  ApiException _mapResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;
    final retryAfter = _retryAfter(response);

    if (data is Map<String, dynamic>) {
      final problem = ProblemDetail.fromJson(data, fallbackStatus: status);

      // A body that is JSON but not a problem (a proxy's `{"error": "..."}`,
      // an HTML-ish gateway page parsed loosely) carries no code and no title;
      // fall back to the status rather than inventing an error type.
      final isProblem =
          problem.code != ApiErrorCode.unknown ||
          problem.title.isNotEmpty ||
          problem.detail != null;

      if (isProblem) {
        final exception = apiExceptionFromProblem(
          problem.traceId == null
              ? _withTraceId(problem, _headerTraceId(response))
              : problem,
          retryAfter: retryAfter,
        );
        if (exception.traceId != null) {
          AppLogger.w(
            '${exception.code.wireValue} ${status ?? ''} '
            '${response?.requestOptions.uri} trace=${exception.traceId}',
            tag: 'ErrorInterceptor',
          );
        }
        return exception;
      }
    }

    return apiExceptionFromProblem(
      ProblemDetail(
        status: status ?? 0,
        code: ApiErrorCode.unknown,
        traceId: _headerTraceId(response),
      ),
      retryAfter: retryAfter,
    );
  }

  ProblemDetail _withTraceId(ProblemDetail problem, String? traceId) {
    if (traceId == null) return problem;
    return ProblemDetail(
      type: problem.type,
      title: problem.title,
      status: problem.status,
      code: problem.code,
      detail: problem.detail,
      traceId: traceId,
      fieldErrors: problem.fieldErrors,
    );
  }

  String? _headerTraceId(Response<dynamic>? response) =>
      response?.headers.value(_requestIdHeader);

  /// `Retry-After` in seconds (the delta-seconds form gokit's rate limiter uses).
  Duration? _retryAfter(Response<dynamic>? response) {
    final raw = response?.headers.value('retry-after');
    final seconds = raw == null ? null : int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
