import 'package:dio/dio.dart';

import '../errors/api_exception.dart';
import '../token_store.dart';

/// Attaches the access token to every request and reacts to `401`.
///
/// Skeleton only: *whether* a token can be refreshed and *what* happens when
/// auth is lost are app rules, injected as [refreshToken] / [onUnauthorized].
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStore,
    this.refreshToken,
    this.onUnauthorized,
    this.headerName = 'Authorization',
    this.scheme = 'Bearer',
  });

  final Dio dio;
  final TokenStore tokenStore;
  final TokenRefresher? refreshToken;
  final void Function()? onUnauthorized;
  final String headerName;
  final String scheme;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skip_auth'] != true) {
      final token = await tokenStore.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[headerName] = '$scheme $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refresher = refreshToken;
    final alreadyRetried = err.requestOptions.extra['auth_retried'] == true;

    if (refresher != null && !alreadyRetried) {
      final refreshed = await refresher();
      if (refreshed) {
        final options = err.requestOptions;
        options.extra['auth_retried'] = true;
        final token = await tokenStore.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers[headerName] = '$scheme $token';
        }
        try {
          handler.resolve(await dio.fetch(options));
          return;
        } on DioException catch (e) {
          handler.reject(e);
          return;
        }
      }
    }

    onUnauthorized?.call();
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: const UnauthorizedException(),
        type: err.type,
        response: err.response,
      ),
    );
  }
}
