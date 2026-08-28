import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kit_config.g.dart';

/// Runtime configuration the **app** supplies to the kit.
///
/// The kit never reads environment variables or `.env` files itself — how an
/// app resolves its base URL (envied, `--dart-define`, remote config…) is an
/// app rule. The app builds a [KitConfig] and hands it to `bootstrapKit`,
/// which overrides [kitConfigProvider] with it.
@immutable
class KitConfig {
  const KitConfig({
    required this.apiBaseUrl,
    this.envLabel = 'dev',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
    this.enableNetworkLogging = kDebugMode,
    this.defaultHeaders = const {},
  });

  /// Base URL every relative request is resolved against.
  final String apiBaseUrl;

  /// Short label for the active environment (`DEV`, `STG`, `PROD`).
  /// Shown in debug banners/logs; never drives behaviour inside the kit.
  final String envLabel;

  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// `0` disables [RetryInterceptor] entirely.
  final int maxRetries;

  /// Base delay between retries — multiplied by the attempt number.
  final Duration retryDelay;

  /// Adds `PrettyDioLogger`. Defaults to debug builds only.
  final bool enableNetworkLogging;

  /// Headers merged into every request (e.g. `x-client-version`).
  final Map<String, String> defaultHeaders;

  KitConfig copyWith({
    String? apiBaseUrl,
    String? envLabel,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    int? maxRetries,
    Duration? retryDelay,
    bool? enableNetworkLogging,
    Map<String, String>? defaultHeaders,
  }) {
    return KitConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      envLabel: envLabel ?? this.envLabel,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      enableNetworkLogging: enableNetworkLogging ?? this.enableNetworkLogging,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
    );
  }

  @override
  String toString() => 'KitConfig($envLabel, $apiBaseUrl)';
}

/// The active [KitConfig].
///
/// Overridden by `bootstrapKit`; in tests override it directly:
/// `kitConfigProvider.overrideWithValue(const KitConfig(apiBaseUrl: '...'))`.
@Riverpod(keepAlive: true)
KitConfig kitConfig(Ref ref) {
  throw UnimplementedError(
    'kitConfigProvider must be overridden with the app KitConfig. '
    'Call bootstrapKit(config: ...) or override it in ProviderScope.',
  );
}
