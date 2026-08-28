// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App rule: extra interceptors appended after the kit's stack — tracing
/// headers, tenant id, mocking, per-service signing. Override this provider.

@ProviderFor(extraInterceptors)
final extraInterceptorsProvider = ExtraInterceptorsProvider._();

/// App rule: extra interceptors appended after the kit's stack — tracing
/// headers, tenant id, mocking, per-service signing. Override this provider.

final class ExtraInterceptorsProvider
    extends
        $FunctionalProvider<
          List<Interceptor>,
          List<Interceptor>,
          List<Interceptor>
        >
    with $Provider<List<Interceptor>> {
  /// App rule: extra interceptors appended after the kit's stack — tracing
  /// headers, tenant id, mocking, per-service signing. Override this provider.
  ExtraInterceptorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'extraInterceptorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$extraInterceptorsHash();

  @$internal
  @override
  $ProviderElement<List<Interceptor>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Interceptor> create(Ref ref) {
    return extraInterceptors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Interceptor> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Interceptor>>(value),
    );
  }
}

String _$extraInterceptorsHash() => r'fe8752182baf8f4a5585ce6902fb3d17edc0c234';

/// The configured [Dio] instance every data source should use.
///
/// Interceptor order (each stage sees what the previous one produced):
///   1. [AuthInterceptor]  — attach token, refresh/replay on 401
///   2. [RetryInterceptor] — retry timeouts and 5xx (skipped when
///      `KitConfig.maxRetries == 0`)
///   3. [ErrorInterceptor] — map `DioException` → [ApiException]
///   4. `PrettyDioLogger`  — when `KitConfig.enableNetworkLogging`
///   5. [extraInterceptors] — app additions

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// The configured [Dio] instance every data source should use.
///
/// Interceptor order (each stage sees what the previous one produced):
///   1. [AuthInterceptor]  — attach token, refresh/replay on 401
///   2. [RetryInterceptor] — retry timeouts and 5xx (skipped when
///      `KitConfig.maxRetries == 0`)
///   3. [ErrorInterceptor] — map `DioException` → [ApiException]
///   4. `PrettyDioLogger`  — when `KitConfig.enableNetworkLogging`
///   5. [extraInterceptors] — app additions

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The configured [Dio] instance every data source should use.
  ///
  /// Interceptor order (each stage sees what the previous one produced):
  ///   1. [AuthInterceptor]  — attach token, refresh/replay on 401
  ///   2. [RetryInterceptor] — retry timeouts and 5xx (skipped when
  ///      `KitConfig.maxRetries == 0`)
  ///   3. [ErrorInterceptor] — map `DioException` → [ApiException]
  ///   4. `PrettyDioLogger`  — when `KitConfig.enableNetworkLogging`
  ///   5. [extraInterceptors] — app additions
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$apiClientHash() => r'0131cafbc1b4865be1e988030deb29b5405f80ba';
