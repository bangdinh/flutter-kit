import 'env.dart';

/// Environment configuration for the app.
///
/// Follows Andrea's tip #37: Rules for good app architecture
/// — externalize config so the same code runs against different backends.
enum AppEnv {
  dev(
    label: 'DEV',
  ),
  staging(
    label: 'STG',
  ),
  prod(
    label: 'PROD',
  );

  const AppEnv({
    required this.label,
  });

  String get apiBaseUrl {
    switch (this) {
      case AppEnv.dev:
        return EnvDev.apiBaseUrl;
      case AppEnv.staging:
        return EnvStaging.apiBaseUrl;
      case AppEnv.prod:
        return EnvProd.apiBaseUrl;
    }
  }

  final String label;

  bool get isDev => this == AppEnv.dev;
  bool get isStaging => this == AppEnv.staging;
  bool get isProd => this == AppEnv.prod;
}

/// Holds the current environment. Set once at app startup.
class EnvConfig {
  EnvConfig._();

  static AppEnv _current = AppEnv.dev;

  static AppEnv get current => _current;

  static void init(AppEnv env) {
    _current = env;
  }
}
