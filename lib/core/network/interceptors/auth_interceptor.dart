import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';
import '../errors/api_exception.dart';

/// Attaches the auth token to every request and handles 401 responses.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.secureStorage});

  final SecureStorage secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic here.
      // For now, just forward the error.
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
