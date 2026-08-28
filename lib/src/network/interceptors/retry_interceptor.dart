import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';

/// Retries failed requests on transient errors (timeout, 5xx).
///
/// Pattern from project_flutter's BaseBloc.callAPI but extracted
/// into an interceptor so it works transparently for all API calls.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

      if (retryCount < maxRetries) {
        AppLogger.w(
          'Retrying request (${retryCount + 1}/$maxRetries): '
          '${err.requestOptions.uri}',
          tag: 'RetryInterceptor',
        );

        await Future.delayed(retryDelay * (retryCount + 1));

        err.requestOptions.extra['retry_count'] = retryCount + 1;

        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (e) {
          handler.reject(e);
          return;
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout => true,
      DioExceptionType.sendTimeout => true,
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.badResponse => _isServerError(err.response?.statusCode),
      _ => false,
    };
  }

  bool _isServerError(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 500 && statusCode < 600;
  }
}
