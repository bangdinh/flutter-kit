# Getting started

## 1. Depend on the kit

```yaml
# pubspec.yaml of your app
dependencies:
  flutter_kit:
    git:
      url: git@github.com:bangdinh/flutter-kit.git
      ref: v0.1.0 # always an exact tag — never a branch
```

Also declare what your app uses directly (the kit does not re-export packages):
`go_router`, `flutter_riverpod`, `riverpod_annotation`, `dio`, `freezed_annotation`,
`json_annotation` — plus the matching dev dependencies (`build_runner`, `riverpod_generator`,
`freezed`, `json_serializable`, `custom_lint`, `riverpod_lint`).

Inherit the lint preset instead of copying rules:

```yaml
# analysis_options.yaml of your app
include: package:flutter_kit/analysis_options.yaml
```

## 2. Resolve your environment (app rule)

The kit takes a plain `KitConfig` and never reads `.env` itself. Use envied, `--dart-define`,
remote config — whatever fits:

```dart
enum AppEnv {
  dev(label: 'DEV'), staging(label: 'STG'), prod(label: 'PROD');
  const AppEnv({required this.label});
  final String label;

  KitConfig toKitConfig() => KitConfig(
        apiBaseUrl: switch (this) { ... },
        envLabel: label,
        enableNetworkLogging: this != AppEnv.prod,
      );
}
```

## 3. Boot

```dart
void main() => bootstrap();

Future<void> bootstrap({AppEnv env = AppEnv.dev}) => bootstrapKit(
      config: env.toKitConfig(),
      appBuilder: () => const MyApp(),
      overrides: [/* your auth rules — see extension-points.md */],
    );
```

`bootstrapKit` initialises the binding, system UI and `SharedPreferences`, then runs your app in a
`ProviderScope` with `kitConfigProvider` and `localStorageProvider` already overridden.

## 4. Root widget + router

```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => KitApp(
        title: 'My App',
        routerConfig: ref.watch(appRouterProvider), // your GoRouter
        theme: KitTheme.light(_brand),
        darkTheme: KitTheme.dark(_brand),
      );
}
```

## 5. First feature

Follow `example/lib/features/auth/` exactly — it is the reference, not a suggestion. Structure and
naming rules are in [architecture.md](architecture.md); the API-call shape is in
[network.md](network.md).

```bash
dart run build_runner build   # after any @riverpod / @freezed / @Envied change
dart analyze lib test
flutter test
```

## Running the example app in this repo

```bash
make get                       # kit + example
cd example && cp .env.dev .env.dev  # env files are gitignored; create your own
make gen-example && make run-dev
```

Each `.env.<flavor>` needs one line: `API_BASE_URL=https://...`.
