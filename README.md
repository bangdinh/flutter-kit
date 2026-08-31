# flutter_kit

Base **library** for FPT B2B Flutter apps — Feature-first Clean Architecture + Riverpod 3.x.

The kit owns the skeleton. Your app owns its rules.

| The kit ships | Your app supplies |
|---|---|
| `bootstrapKit` · `KitApp` · `KitConfig` | environment resolution, routes, features |
| Dio stack: auth → retry → error mapping | auth policy (`TokenStore`, refresh, logout) |
| the b2b-gokit contract: `data` envelope, cursor pages, RFC 9457 errors | brand palette, copy, product decisions |
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

## Start an app from it

```bash
make new-app NAME=camera_b2b ORG=vn.fpt   # → ../camera_b2b, kit pinned to the latest tag
cd ../camera_b2b && cp .env.example .env.dev
make gen && make ci
make feature NAME=profile                 # scaffold a feature, from the kit
```

The generated app ships its own Makefile, CI, docs and the `feature-flow` / `flutter-arch` /
`git-flow` skills. Details: [docs/scaffold.md](docs/scaffold.md).

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
bin/                        scaffold.dart (new app) · new_feature.dart (new feature)
templates/                  app/ and feature/ templates the generators render
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
| [scaffold.md](docs/scaffold.md) | generating an app or a feature |
| [api-contract.md](docs/api-contract.md) | the b2b-gokit wire contract the kit implements |
| [network.md](docs/network.md) | API calls, errors, tokens, pagination |
| [state.md](docs/state.md) | Riverpod 3.x rules, bootstrap, lifecycle |
| [theme.md](docs/theme.md) | rebranding, spacing, shared widgets |
| [testing.md](docs/testing.md) | provider/widget tests, overriding the kit |
| [versioning.md](docs/versioning.md) | releasing and pinning |
