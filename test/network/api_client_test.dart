import 'package:dio/dio.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const _config = KitConfig(
  apiBaseUrl: 'https://api.example.com',
  envLabel: 'TEST',
  enableNetworkLogging: false,
);

ProviderContainer _container({
  KitConfig config = _config,
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: [kitConfigProvider.overrideWithValue(config), ...overrides],
  );
  addTearDown(container.dispose);
  return container;
}

class _MarkerInterceptor extends Interceptor {}

void main() {
  group('apiClientProvider', () {
    test('applies base options from KitConfig', () {
      final dio = _container().read(apiClientProvider);

      expect(dio.options.baseUrl, 'https://api.example.com');
      expect(dio.options.connectTimeout, _config.connectTimeout);
      expect(dio.options.contentType, Headers.jsonContentType);
    });

    test('merges KitConfig.defaultHeaders into every request', () {
      final dio = _container(
        config: _config.copyWith(defaultHeaders: {'x-client-version': '1.2.3'}),
      ).read(apiClientProvider);

      expect(dio.options.headers['x-client-version'], '1.2.3');
    });

    test('installs auth + retry + error interceptors by default', () {
      final dio = _container().read(apiClientProvider);

      expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
      expect(dio.interceptors.whereType<RetryInterceptor>(), hasLength(1));
      expect(dio.interceptors.whereType<ErrorInterceptor>(), hasLength(1));
    });

    test('maxRetries = 0 removes the retry interceptor', () {
      final dio = _container(
        config: _config.copyWith(maxRetries: 0),
      ).read(apiClientProvider);

      expect(dio.interceptors.whereType<RetryInterceptor>(), isEmpty);
    });

    test('appends app-supplied extraInterceptors last', () {
      final dio = _container(
        overrides: [
          extraInterceptorsProvider.overrideWithValue([_MarkerInterceptor()]),
        ],
      ).read(apiClientProvider);

      expect(dio.interceptors.last, isA<_MarkerInterceptor>());
    });
  });
}
