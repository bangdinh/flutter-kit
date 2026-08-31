import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../logging/app_logger.dart';
import '../storage/local_storage.dart';
import 'kit_config.dart';

/// Riverpod's retry signature: return the delay before the next attempt, or
/// `null` to stop retrying. Structurally identical to Riverpod's own `Retry`,
/// which the package does not export.
typedef ProviderRetry = Duration? Function(int retryCount, Object error);

/// Never retry at the provider level — the kit's default. See
/// `bootstrapKit`'s `providerRetry`.
Duration? kitNoProviderRetry(int retryCount, Object error) => null;

/// Boots a kit-based app: binding, system UI, async dependencies, then
/// `runApp` inside a `ProviderScope`.
///
/// Async dependencies are resolved *before* `runApp` and injected as provider
/// overrides, so feature code reads them synchronously (no `FutureProvider`
/// for `SharedPreferences`).
///
///   ```dart
///   void main() => bootstrapKit(
///         config: KitConfig(apiBaseUrl: Env.apiBaseUrl, envLabel: 'DEV'),
///         appBuilder: () => const MyApp(),
///         overrides: [tokenRefresherProvider.overrideWithValue(refresh)],
///       );
///   ```
Future<void> bootstrapKit({
  required KitConfig config,
  required Widget Function() appBuilder,

  /// App-specific provider overrides (auth rules, feature flags, fakes).
  List<Override> overrides = const [],

  /// Runs after the binding is ready, before `runApp` — Firebase.initializeApp,
  /// Hive.init, license registration.
  FutureOr<void> Function()? onInit,
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],

  /// Usually leave this unset: [KitApp] applies a theme-aware, edge-to-edge
  /// style per frame (see `kitSystemUiOverlayStyle`), which a value fixed at
  /// boot would only fight with. Set it for an app that doesn't use [KitApp].
  SystemUiOverlayStyle? systemUiOverlayStyle,

  /// Called for every uncaught framework error. Defaults to logging it.
  void Function(Object error, StackTrace stackTrace)? onError,

  /// Riverpod's provider-level retry policy.
  ///
  /// Defaults to [kitNoProviderRetry] — **off**. Riverpod 3 otherwise retries
  /// any provider whose build throws a non-`Error`, up to 10 times with
  /// exponential backoff, which for this kit is the wrong layer: the Dio
  /// [RetryInterceptor] already retries transient failures where a timeout or a
  /// 5xx can be told apart from a 404, and it does so before a `Result` is ever
  /// produced. Leaving both on means a `NotFoundException` is retried for tens
  /// of seconds while the UI sits in `AsyncLoading`.
  ///
  /// Pass Riverpod's `ProviderContainer.defaultRetry` (or your own) to opt in.
  ProviderRetry? providerRetry = kitNoProviderRetry,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    if (onError != null) {
      onError(details.exception, details.stack ?? StackTrace.current);
    } else {
      AppLogger.e(
        details.exceptionAsString(),
        error: details.exception,
        stackTrace: details.stack,
      );
    }
  };

  AppLogger.i('Starting app — ${config.envLabel} (${config.apiBaseUrl})');

  if (systemUiOverlayStyle != null) {
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  if (orientations.isNotEmpty) {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  await onInit?.call();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      retry: providerRetry,
      overrides: [
        kitConfigProvider.overrideWithValue(config),
        localStorageProvider.overrideWithValue(sharedPreferences),
        ...overrides,
      ],
      child: appBuilder(),
    ),
  );
}
