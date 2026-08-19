/// Environment configuration for the app.
///
/// Follows Andrea's tip #37: Rules for good app architecture
/// — externalize config so the same code runs against different backends.
enum AppEnv {
  dev(
    apiBaseUrl: 'https://api.dev.example.com',
    label: 'DEV',
  ),
  staging(
    apiBaseUrl: 'https://api.staging.example.com',
    label: 'STG',
  ),
  prod(
    apiBaseUrl: 'https://api.example.com',
    label: 'PROD',
  );

  const AppEnv({
    required this.apiBaseUrl,
    required this.label,
  });

  final String apiBaseUrl;
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
