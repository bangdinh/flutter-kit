import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app/kit_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'token_store.dart';

part 'api_client.g.dart';

/// App rule: extra interceptors appended after the kit's stack — tracing
/// headers, tenant id, mocking, per-service signing. Override this provider.
@Riverpod(keepAlive: true)
List<Interceptor> extraInterceptors(Ref ref) => const [];

/// The configured [Dio] instance every data source should use.
///
/// Interceptor order (each stage sees what the previous one produced):
///   1. [AuthInterceptor]  — attach token, refresh/replay on 401
///   2. [RetryInterceptor] — retry timeouts and 5xx (skipped when
///      `KitConfig.maxRetries == 0`)
///   3. [ErrorInterceptor] — map `DioException` → [ApiException]
///   4. `PrettyDioLogger`  — when `KitConfig.enableNetworkLogging`
///   5. [extraInterceptors] — app additions
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final config = ref.watch(kitConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      contentType: Headers.jsonContentType,
      headers: {...config.defaultHeaders},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokenStore: ref.watch(tokenStoreProvider),
      refreshToken: ref.watch(tokenRefresherProvider),
      onUnauthorized: ref.watch(unauthorizedHandlerProvider),
    ),
  );

  if (config.maxRetries > 0) {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: config.maxRetries,
        retryDelay: config.retryDelay,
      ),
    );
  }

  dio.interceptors.add(ErrorInterceptor());

  if (config.enableNetworkLogging) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
      ),
    );
  }

  dio.interceptors.addAll(ref.watch(extraInterceptorsProvider));

  ref.onDispose(dio.close);

  return dio;
}
