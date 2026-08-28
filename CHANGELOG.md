# Changelog

All notable changes to `flutter_kit`. Format follows [Keep a Changelog](https://keepachangelog.com);
versioning follows [docs/versioning.md](docs/versioning.md) (pre-1.0: MINOR = feature *or* breaking,
PATCH = compatible fix).

## [Unreleased]

### Breaking

- Restructured from an app template into a consumable **library**. Everything moved behind
  `lib/src/` and is reachable only through the `package:flutter_kit/flutter_kit.dart` barrel; the old
  `core/core.dart` and `shared/shared.dart` barrels are gone.
- The kit no longer owns environment, routes or the sample feature. `AppEnv`/`EnvConfig`,
  `GoRouter`, `RoutePaths` and `features/auth/` moved to `example/`. An app passes a `KitConfig` and
  its own `RouterConfig` instead.
- `AppTheme.light`/`.dark` (static getters over a fixed `AppColors`) → `KitTheme.light(colors)` /
  `KitTheme.dark(colors)` taking `KitColors` tokens. `AppColors` is gone.
- `bootstrap()` → `bootstrapKit(config:, appBuilder:, overrides:, onInit:, onError:)`.
- `AuthInterceptor` now depends on `TokenStore` instead of `SecureStorage`, and takes explicit
  `refreshToken` / `onUnauthorized` hooks instead of a `TODO`.

### Added

- `KitConfig` + `kitConfigProvider`: base URL, timeouts, retry policy, default headers, logging
  switch — supplied by the app, never read from `.env` by the kit.
- `KitApp`: `MaterialApp.router` shell wired to the persisted `themeModeProvider`.
- `TokenStore` contract with a `SecureTokenStore` default, plus `tokenRefresherProvider` and
  `unauthorizedHandlerProvider` for the app's auth policy; `Options(extra: {'skip_auth': true})`
  skips token attachment per request.
- `extraInterceptorsProvider` — app interceptors appended after the kit's stack.
- `ApiErrorMessages` + `apiErrorMessagesProvider` — overridable user-facing error copy.
- `KitColors` palette tokens; `RetryInterceptor` now configured from `KitConfig` (`maxRetries: 0`
  removes it).
- Lint preset shipped at `package:flutter_kit/analysis_options.yaml`.
- `example/`: reference app showing env resolution, router, brand palette and a feature on kit
  contracts. Built and tested in CI.
- Docs (`docs/`, ADR 0001), `CONTRIBUTING.md`, `.claude/skills/{flutter-arch,git-flow}`,
  `scripts/release.sh` + `make release`.

### Fixed

- CI ran against `main` while the repo's default branch is `master`; it now also analyzes and tests
  the example app.
- `dart analyze` replaces `flutter analyze` in Makefile and CI (the analysis server crashes on some
  machines).
- `apiClientProvider` closes its `Dio` on dispose.
