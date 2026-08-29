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
- `bootstrap()` → `bootstrapKit(config:, appBuilder:, overrides:, onInit:, onError:)`. Its
  `systemUiOverlayStyle` is now nullable and unset by default — `KitApp` applies a theme-aware style
  per frame, which a value fixed at boot would fight with.
- `AuthInterceptor` now depends on `TokenStore` instead of `SecureStorage`, and takes explicit
  `refreshToken` / `onUnauthorized` hooks instead of a `TODO`.

### Added

- **Scaffolding**: `bin/scaffold.dart` generates a new app (`make new-app NAME=… ORG=…`) — it runs
  `flutter create` for the platform folders and overlays `templates/app/`: pubspec with the kit
  pinned to a tag, lint preset, `lib/` wiring, smoke test, Makefile, PR-only CI, `.env.example`,
  docs and the `feature-flow` / `flutter-arch` / `git-flow` skills.
- `bin/new_feature.dart` generates one feature inside an app (`make feature NAME=profile`), reachable
  as `dart run flutter_kit:new_feature` from any app that depends on the kit — full
  data/domain/presentation folder plus a fake repository and a provider test.
- Skills: **flutter-testing** (fakes, provider/widget test setup, the Riverpod 3 retry and
  auto-dispose traps), **kit-extension-point** (contract + default + provider instead of forking) and
  **kit-scaffold** (generators and templates, kit-only), alongside the existing flutter-arch and
  git-flow.
- `make sync-skill` / `make verify-skill` keep `flutter-arch` and `flutter-testing` identical between
  the kit and the app template; CI fails on drift.
- `bootstrapKit(providerRetry:)` with `kitNoProviderRetry` as the default — Riverpod 3 otherwise
  retries any throwing provider 10 times with backoff, which would keep the UI loading for ~30s on a
  404. Retry stays in the HTTP layer, where 5xx and 404 can be told apart.
- `KitConfig` + `kitConfigProvider`: base URL, timeouts, retry policy, default headers, logging
  switch — supplied by the app, never read from `.env` by the kit.
- `KitApp`: `MaterialApp.router` shell wired to the persisted `themeModeProvider`. Opts into
  `SystemUiMode.edgeToEdge` (enforced by Android from API 35) and annotates each frame with
  `kitSystemUiOverlayStyle(brightness)` — transparent bars, icon brightness following the resolved
  theme. Opt out with `KitApp(edgeToEdge: false)`.
- `kitSystemUiOverlayStyle(Brightness)` — the kit's bar style, exported so a screen can annotate
  itself differently from the app's theme.
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
- `example/`: Android build failed with `JetifyTransform ... Java heap space` — Jetifier was left
  enabled and rewrote Flutter's engine jars. Disabled (`checkJetifier` confirms nothing needs it)
  and raised `org.gradle.jvmargs` to the current Flutter template value.
- `example/`: `targetSdkVersion` 34 → 36, matching `compileSdkVersion`.
