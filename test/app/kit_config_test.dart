import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KitConfig', () {
    test('defaults are sane for a service call', () {
      const config = KitConfig(apiBaseUrl: 'https://api.example.com');

      expect(config.envLabel, 'dev');
      expect(config.connectTimeout, const Duration(seconds: 30));
      expect(config.maxRetries, 2);
      expect(config.defaultHeaders, isEmpty);
    });

    test('copyWith replaces only the given fields', () {
      const config = KitConfig(apiBaseUrl: 'https://api.example.com');

      final prod = config.copyWith(
        apiBaseUrl: 'https://api.prod.example.com',
        envLabel: 'PROD',
        enableNetworkLogging: false,
      );

      expect(prod.apiBaseUrl, 'https://api.prod.example.com');
      expect(prod.envLabel, 'PROD');
      expect(prod.enableNetworkLogging, isFalse);
      expect(prod.maxRetries, config.maxRetries);
    });
  });

  group('kitConfigProvider', () {
    test('throws when the app forgot to supply a config', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Riverpod 3 wraps a provider's error, so assert on the cause.
      expect(
        () => container.read(kitConfigProvider),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.exception,
            'exception',
            isUnimplementedError,
          ),
        ),
      );
    });
  });
}
