# CLAUDE.md

Guidance for Claude Code in this repo. **Keep this file lean** — it loads into every prompt. Detail
goes in `docs/`; behaviour rules go in the skills (below). Here: only high-signal facts that prevent
wrong guesses, loops and redo.

## What this is

`flutter_kit` = base **library** for FPT B2B Flutter apps (Feature-first Clean Architecture +
Riverpod 3.x). It ships the app shell (`bootstrapKit`, `KitApp`), the Dio stack (auth → retry →
error mapping), storage, `Result`/pagination, the theme system and shared widgets. Apps depend on a
pinned git tag and supply their own rules: environment resolution, routes, features, auth policy,
palette, copy.

Not a template — nothing is meant to be copied out. `example/` is a real app consuming the kit by
path, and CI builds it to prove the public API still works for a consumer.

## Ground truth — this is a base **source-code** library

Other apps depend on this. Correctness over cleverness.

- **The source is the authority.** Before writing anything, search for an existing helper and reuse
  it (`apiCall`, `Result`, `ApiException`, `AppSizes`, `AsyncValueWidget`, `PaginatedNotifier`,
  `KitTheme`). Recreating something that exists is a defect — check first.
- **Don't fabricate.** If a symbol, signature or behaviour isn't in the source and you're unsure,
  read the code. Never invent an API or a "convention" that isn't there. If it genuinely doesn't
  exist, say so and propose adding it.
- **New patterns need a basis.** Ground anything new in the framework's own docs or a widely-used,
  actively-maintained package — and say where it came from. No cargo-culting.

## Layout

```
lib/flutter_kit.dart      the ONLY public surface (barrel)   docs/          architecture, network, state, theme, testing…
bin/ + templates/         scaffold CLIs + app/feature templates (docs/scaffold.md)
lib/analysis_options.yaml lint preset apps `include:`         example/       reference app (separate package)
lib/src/app/              KitConfig · bootstrapKit · KitApp   test/          kit tests
lib/src/network/          Dio stack · TokenStore · errors     scripts/       release.sh
lib/src/storage/          prefs + secure storage providers    build.yaml     keeps kit codegen out of example/
lib/src/theme/  ui/       KitColors · KitTheme · AppSizes · shared widgets
lib/src/models/           Result<T> · PaginatedState<T>
lib/src/providers/        themeMode · appLifecycle
```

## Scaffolding

```bash
make new-app NAME=camera_b2b ORG=vn.fpt   # new app  → ../camera_b2b (bin/scaffold.dart)
make feature NAME=profile                 # inside an app (bin/new_feature.dart)
```

`bin/scaffold.dart` runs `flutter create` for `android/`+`ios/` and only overlays what the kit owns
(`templates/app/`). `flutter-arch/SKILL.md` is shared **verbatim** with `templates/app/` — edit the
kit copy, then `make sync-skill`; `make verify-skill` and CI fail on drift. A template change is not
verified until a generated app passes its own `make ci` — see `docs/scaffold.md`.

## Verify — use these exact commands

```bash
dart run build_runner build && dart analyze lib test && flutter test           # the kit
cd example && dart run build_runner build && dart analyze lib test && flutter test   # the app
make ci                                                                        # both
```

- **Use `dart analyze`, not `flutter analyze`** — `flutter analyze` crashes on this machine
  (analysis server exits 64, Homebrew dart conflict). CI uses `dart analyze` for the same reason.
- Chain edit → gen → analyze → test with `&&`. Regenerate after touching `@riverpod`, `@freezed`,
  `@Envied`.
- **Generated code is committed in both packages** — an app consuming the kit by tag cannot generate
  code for a dependency (`build_runner` only runs on the current package), and having the output in
  git makes a bad build traceable to a diff instead of to someone's local generator state. Run
  `make gen` / `make gen-example` and commit the result; CI fails on a stale one. The single
  exception is `env.g.dart`: envied embeds the `.env` values into it, and obfuscation is not
  encryption — it stays untracked, like `.env*`.
- The kit and `example/` are **separate packages** — `pub get`/codegen/analyze/test each. `build.yaml`
  deliberately excludes `example/**` from the kit's build_runner (otherwise codegen fails on the
  app's own dependencies, e.g. go_router).

## Git — propose, never execute

**Never `git commit`, `git push` or `git tag` on your own.** Propose the exact commands (branch,
full commit message, push/tag) and let the user run them — even when the task "obviously" needs a
commit. Editing/staging files is fine. The user often works in parallel: check `git status` before
touching the index, and never `git add -A`.

## Conventions (non-negotiable — don't re-derive)

Flutter `3.41.x` · Dart SDK `^3.7.0` · Riverpod `3.x`.

- **Kit or app?** Add to the kit only what a second app would want unchanged. Product decisions
  (endpoint paths, wording, brand values, flags) are app rules — add an *extension point* (contract +
  default + overridable provider), never an app-specific branch inside the kit. See
  `docs/extension-points.md`.
- **Public API** = what `lib/flutter_kit.dart` exports. New public symbol → export it there, document
  it in `docs/`, add a `## [Unreleased]` entry in `CHANGELOG.md`.
- **Providers**: `@riverpod` codegen only; functional providers take `Ref`; generated name drops
  `Notifier`; `@Riverpod(keepAlive: true)` for app-lifetime singletons only.
- **Network**: get Dio from `apiClientProvider`; repositories return `Result<T>` via `apiCall`;
  errors are the sealed `ApiException`; user copy via `apiErrorMessagesProvider`.
- **Layers**: `domain/` imports nothing (no flutter, no dio); `presentation/` reaches `data/` only
  through providers.
- **TDD**: failing test first. An extension point needs a test for the default *and* for an override.
- **Do NOT** add `get_it`/`injectable` (Riverpod is the DI container), use `valueOrNull` (gone in
  3.x), use `XxxRef` types (2.x), or import `package:flutter_kit/src/...` from an app.

## Repo gotchas (these cause loops if unknown)

- Default branch is **`master`** (not `main`) — remote `git@github.com:bangdinh/flutter-kit.git`.
- **CI runs on PRs into `master` and on manual dispatch only** — not on push. A green local `make ci`
  is the feedback loop while working; to get a run on a branch before the PR, trigger the workflow
  manually (Actions → CI → Run workflow).
- `example/pubspec.lock` **is** committed (it's an app, and it keeps codegen output reproducible);
  the kit's own lock stays ignored (it's a library).
- `Override` and `ProviderException` are **not** exported by `flutter_riverpod.dart` — import
  `package:flutter_riverpod/misc.dart show Override, ProviderException`.
- Current `build_runner` rejects `--delete-conflicting-outputs` (removed flag). Just
  `dart run build_runner build`.
- `example/.env.*` are gitignored; a fresh clone must create them (`API_BASE_URL=...`) or codegen
  fails. CI seeds them.
- Re-tagging a published version poisons `pub` caches of apps pinning it — ship a new version.
- **Riverpod 3 retries a throwing provider by default** (10×, 200ms→6.4s) — `bootstrapKit` turns
  that off (`kitNoProviderRetry`) because `RetryInterceptor` owns retry where 5xx and 404 differ. A
  bare `ProviderContainer` in a test still uses the default and will hang an error-path test: pass
  `retry: (_, _) => null`. Reading `provider.future` also needs a live `container.listen`, or the
  auto-dispose provider dies mid-load.

## Follow the skills (auto-applied)

Five skills under `.claude/skills/` trigger on their `description` — **complying with them is
enough; you don't need to read the docs**. Each owns one scope (don't cross):

- **flutter-arch** — where code belongs, layer rules, Riverpod/network/theme conventions.
- **flutter-testing** — writing/fixing tests, fakes, the Riverpod 3 traps that hang a test.
- **kit-extension-point** — an app needs something the kit lacks: contract + default + provider.
- **kit-scaffold** — `bin/` generators and `templates/**` (kit-only).
- **git-flow** — branches, commits, PR checklist, SemVer tag + CHANGELOG.

`flutter-arch` and `flutter-testing` ship verbatim into generated apps (`make sync-skill`);
`kit-scaffold` and `kit-extension-point` are kit-only.
