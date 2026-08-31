# Scaffolding

Two generators, both living in the kit so every app starts — and stays — the same shape.

## A new app

```bash
git clone git@github.com:bangdinh/flutter-kit.git && cd flutter-kit
make new-app NAME=camera_b2b ORG=vn.fpt           # → ../camera_b2b
```

Under the hood (`bin/scaffold.dart`):

1. Validates the package name and org the way `flutter create` would, but with a readable error.
2. Runs **`flutter create`** for the platform folders. The kit does not template `android/` or
   `ios/` — bundle ids, Kotlin package paths and Gradle files are Flutter's to generate, and a
   template copy of them rots the moment Flutter changes.
3. Overlays `templates/app/` with placeholder substitution: `pubspec.yaml` (kit pinned to a tag),
   `analysis_options.yaml` (kit preset), `lib/`, `test/`, `Makefile`, CI, `.gitignore`,
   `.env.example`, `CLAUDE.md`, `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, and the three
   skills (`feature-flow`, `flutter-arch`, `git-flow`).
4. `flutter pub get` + `build_runner` (skip with `--no-pub` / `--no-gen`).

| Flag | Effect |
|---|---|
| `--name` | required, `lower_snake_case` |
| `--org` | bundle id prefix, default `vn.fpt` |
| `--out` | output dir, default `../<name>` |
| `--kit-ref vX.Y.Z` | tag to pin; defaults to the newest tag in this checkout |
| `--local` | depend on this working tree by path — **dev only**, never commit it |
| `--platforms` | passed to `flutter create` (default `android,ios`) |
| `--description` | pubspec description |

The generator refuses to write into a non-empty directory. Nothing is committed and no remote is
touched — it prints the `git init` command for you to run.

First run in the new app:

```bash
cp .env.example .env.dev   # and .env.staging / .env.prod
make gen && make ci
```

## A feature, inside an app

```bash
make feature NAME=profile        # → dart run flutter_kit:new_feature profile
```

The generator lives in the kit and is reachable from any app that depends on it — the engine finds
`templates/` through the app's `package_config.json`, so it works from a git dependency in the pub
cache. It writes the whole three-layer folder plus a fake repository and a provider test, and never
overwrites a file that already exists (it reports those as `=`).

Then: `make gen`, fix the guessed endpoint, add the route, and follow the order in the app's
`feature-flow` skill.

## Templates

```
templates/app/       one app: pubspec, lints, lib/, test/, Makefile, CI, docs, skills
templates/feature/   one feature: data/ domain/ presentation/ + test/
```

- Placeholders are `__name__`, `__Name__`, `__title__`, `__org__`, `__kit_ref__`,
  `__kit_dependency__`, and for features `__feature__`, `__Feature__`, `__features__`. An unknown
  `__token__` is left in the output on purpose — a visible placeholder beats a silently blank file.
- Dart files and pubspecs carry a `.tmpl` suffix, stripped on render. Without it the analyzer would
  try to resolve `package:__name__/...` inside this repo.
- `flutter-arch/SKILL.md` is **shared verbatim** with the kit: edit the kit's copy, then
  `make sync-skill`. `make verify-skill` (and CI) fails if the two drift. `feature-flow` and the
  app's `git-flow` are app-only and live in `templates/` alone.
- `test/tools/scaffold_engine_test.dart` renders both templates and asserts no placeholder survives
  and that the domain layer stays free of `flutter`/`dio` imports. A template change that breaks the
  architecture rules fails here.

## Changing a template

1. Edit under `templates/`.
2. `flutter test test/tools` — the render tests.
3. Generate for real and run the app's own CI, because a template that renders is not the same as a
   template that compiles:

```bash
make new-app NAME=tmp_check OUT=/tmp/tmp_check EXTRA="--local"
cd /tmp/tmp_check && for e in dev staging prod; do cp .env.example .env.$e; done
make gen && make ci && make feature NAME=probe && make gen && make ci
```
