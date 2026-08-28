import 'package:flutter_kit/flutter_kit.dart';

import 'env.dart';

/// **App rule**: how this app resolves its environment.
///
/// The kit takes a plain [KitConfig] and never reads `.env` files itself, so
/// an app is free to use envied (here), `--dart-define`, or remote config.
enum AppEnv {
  dev(label: 'DEV'),
  staging(label: 'STG'),
  prod(label: 'PROD');

  const AppEnv({required this.label});

  final String label;

  String get apiBaseUrl => switch (this) {
    AppEnv.dev => EnvDev.apiBaseUrl,
    AppEnv.staging => EnvStaging.apiBaseUrl,
    AppEnv.prod => EnvProd.apiBaseUrl,
  };

  bool get isDev => this == AppEnv.dev;
  bool get isStaging => this == AppEnv.staging;
  bool get isProd => this == AppEnv.prod;

  /// Translates the app's environment into the kit's config contract.
  KitConfig toKitConfig() => KitConfig(
    apiBaseUrl: apiBaseUrl,
    envLabel: label,
    // App rule: never log request bodies against production.
    enableNetworkLogging: !isProd,
  );
}
