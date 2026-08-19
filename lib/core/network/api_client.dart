import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/env/app_env.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

part 'api_client.g.dart';

/// Provides a configured [Dio] instance.
///
/// Interceptor stack order:
///   1. AuthInterceptor — attaches token, handles 401
///   2. RetryInterceptor — retries on timeout / 5xx
///   3. ErrorInterceptor — maps Dio errors to ApiException
///   4. PrettyDioLogger — logs requests (debug only)
@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.current.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  // 1. Auth
  dio.interceptors.add(
    AuthInterceptor(secureStorage: ref.watch(secureStorageProvider)),
  );

  // 2. Retry (max 2 retries on timeout / 5xx)
  dio.interceptors.add(
    RetryInterceptor(dio: dio),
  );

  // 3. Error mapping
  dio.interceptors.add(ErrorInterceptor());

  // 4. Logging (debug only)
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
      ),
    );
  }

  return dio;
}
