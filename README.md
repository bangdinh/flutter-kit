# flutter_kit

Base **library** for FPT B2B Flutter apps — Feature-first Clean Architecture + Riverpod 3.x.

The kit owns the skeleton. Your app owns its rules.

| The kit ships | Your app supplies |
|---|---|
| `bootstrapKit` · `KitApp` · `KitConfig` | environment resolution, routes, features |
| Dio stack: auth → retry → error mapping | auth policy (`TokenStore`, refresh, logout) |
| `Result<T>` · sealed `ApiException` · pagination | brand palette, copy, product decisions |
| `KitTheme`/`KitColors` · `AppSizes` · shared widgets | anything a second app wouldn't want verbatim |
| lint preset (`package:flutter_kit/analysis_options.yaml`) | |

Not a template: apps depend on a pinned tag and get fixes by bumping it — see
[ADR 0001](docs/adr/0001-library-not-template.md).

## Use it

```yaml
dependencies:
  flutter_kit:
    git:
      url: git@github.com:bangdinh/flutter-kit.git
      ref: v0.1.0 # exact tag, never a branch
```

```dart
void main() => bootstrapKit(
      config: KitConfig(apiBaseUrl: Env.apiBaseUrl, envLabel: 'DEV'),
      appBuilder: () => const MyApp(),
      overrides: [
        // app rules — see docs/extension-points.md
        unauthorizedHandlerProvider.overrideWithValue(logout),
      ],
    );

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => KitApp(
        title: 'My App',
        routerConfig: ref.watch(appRouterProvider), // your GoRouter
        theme: KitTheme.light(brand),
        darkTheme: KitTheme.dark(brand),
      );
}
```

Full walkthrough: [docs/getting-started.md](docs/getting-started.md).

## Layout

```
lib/flutter_kit.dart        the only public surface (barrel)
lib/analysis_options.yaml   lint preset apps `include:`
lib/src/app/                KitConfig · bootstrapKit · KitApp
lib/src/network/            Dio client · interceptors · TokenStore · ApiException · apiCall
lib/src/storage/            SharedPreferences + secure storage providers
lib/src/models/             Result<T> · PaginatedState<T>
lib/src/theme/  ui/         KitColors · KitTheme · AppSizes · shared widgets
lib/src/providers/          themeMode (persisted) · appLifecycle
example/                    reference app consuming the kit by path (built in CI)
docs/                       architecture · network · state · theme · testing · versioning · ADRs
```

## Develop

```bash
make get      # pub get (kit + example)
make gen      # build_runner for the kit
make analyze  # dart analyze — `flutter analyze` crashes on some machines
make test
make ci       # everything CI runs, kit + example
```

`make help` lists all targets. Contributing rules: [CONTRIBUTING.md](CONTRIBUTING.md).
Release: `make release VERSION=vX.Y.Z` (see [docs/versioning.md](docs/versioning.md)).

## Docs

| Doc | Read it when |
|---|---|
| [getting-started.md](docs/getting-started.md) | standing up a new app |
| [architecture.md](docs/architecture.md) | deciding where code belongs |
| [extension-points.md](docs/extension-points.md) | the kit doesn't do what you need |
| [network.md](docs/network.md) | API calls, errors, tokens, pagination |
| [state.md](docs/state.md) | Riverpod 3.x rules, bootstrap, lifecycle |
| [theme.md](docs/theme.md) | rebranding, spacing, shared widgets |
| [testing.md](docs/testing.md) | provider/widget tests, overriding the kit |
| [versioning.md](docs/versioning.md) | releasing and pinning |
