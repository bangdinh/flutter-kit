# ADR 0001 — flutter_kit is a library, not a project template

- **Status**: accepted
- **Date**: 2026-08-28

## Context

flutter_kit started as a template repo: clone it, rename the project, delete the sample feature,
start building. After the first two apps it was clear this doesn't hold — a fix to the Dio stack or
the error contract lives in whichever copy it was made in, and there is no mechanism to bring it to
the others. b2b-gokit (the Go framework the same teams use) had already settled the question:
services depend on a pinned module version and re-tag to upgrade.

Two layouts were considered:

- **A. one package + `example/`** — kit is a single Flutter package; apps depend on it by git tag.
- **B. melos monorepo** — `flutter_kit_core` / `_network` / `_ui` / `_lints` as separate packages.

## Decision

Layout **A**: one package `flutter_kit`, consumed via `git: { ref: vX.Y.Z }`, with `example/` as an
app that consumes it by path and is exercised in CI.

## Rationale

- **One version, one tag.** B multiplies versions and forces a coordinated bump across packages for
  every `core` breaking change. A matches gokit's one-tag model, which the team already runs.
- **B's inter-package `path:` deps don't survive git consumption.** Packages inside a monorepo refer
  to each other by path; an app pulling one of them by `git:` has to resolve that path through the
  checkout. The robust fix is a private pub server, which we don't have — leaving
  `dependency_overrides` in every app as the workaround.
- **B's real wins are not urgent.** Not shipping unused dependencies, and compiler-enforced layer
  boundaries, matter at several apps. At one or two, the lint preset (shipped from A as
  `lib/analysis_options.yaml`) covers most of it.

## Consequences

- Apps pull the kit's full dependency set (dio, secure storage, cached_network_image) even when
  unused. Accepted — same trade-off as gokit shipping postgres and kafka in one module.
- `lib/src/**` must stay private and `lib/flutter_kit.dart` curated, since there is no package
  boundary enforcing it. This is the versioning promise in `docs/versioning.md`.
- Kit code must not read `.env`, route tables or product wording — those move to the app, which is
  why `KitConfig`, `KitApp(routerConfig:)` and the override providers exist.
- If a third and fourth app arrive, or a private pub server appears, splitting to B is a directory
  move: `lib/src/network/` → `packages/flutter_kit_network/lib/` plus a pubspec. Keep `lib/src/`
  subsystem folders clean so that stays true.
