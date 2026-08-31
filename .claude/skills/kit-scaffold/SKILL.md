---
name: kit-scaffold
description: Use when changing the generators or templates in flutter-kit — bin/scaffold.dart, bin/new_feature.dart, templates/app/**, templates/feature/**, the shared-skill sync, or when a generated app fails to build. Kit repo only. Trigger khi "sửa template", "scaffold", "make new-app", "make feature", "app sinh ra bị lỗi", "thêm file vào app mẫu", "generator".
---

# kit-scaffold (flutter-kit only)

Reference: `docs/scaffold.md`. Everything a generated app starts life with is here, so a mistake
ships to every future app at once.

```
bin/scaffold.dart        new app: flutter create + overlay templates/app
bin/new_feature.dart     new feature inside an app: overlay templates/feature
lib/src/tools/scaffold_engine.dart   substitution, validation, kit-root resolution
templates/app/  templates/feature/
```

## Rules that keep the generators honest

- **Never template `android/` or `ios/`.** `flutter create` generates them (bundle ids, Kotlin
  package paths, Gradle) and keeps them current; a template copy rots silently.
- **The kit overlays only what it owns**: pubspec, lints, `lib/`, `test/`, Makefile, CI, `.gitignore`,
  `.env.example`, docs, skills.
- **`.tmpl` suffix on Dart files and pubspecs**, stripped on render. Without it the analyzer tries to
  resolve `package:__name__/...` inside this repo and `dart analyze` fails.
- **Placeholders**: app — `__name__`, `__Name__`, `__title__`, `__org__`, `__description__`,
  `__kit_ref__`, `__kit_dependency__`; feature — `__feature__`, `__Feature__`, `__features__`,
  `__title__`, `__name__`. They substitute in **paths and content**. An unknown `__token__` is left
  visible on purpose — never "fix" that by blanking it.
- **`new_feature` must not overwrite**: it renders with `overwrite: false` and reports skips. Keep it
  that way; it runs inside a repo with real work in it.
- **A new pubspec dependency in the template needs a reason a *typical* app shares.** One app's need
  is that app's dependency.
- **A template must obey the architecture it teaches.** `domain/` with a `flutter` or `dio` import,
  a widget holding business logic, a hand-written `Provider` — the generated code is what people
  copy next.

## Shared skill files

`flutter-arch/SKILL.md` is shared **verbatim** kit → `templates/app/`. Edit the kit's copy, then:

```bash
make sync-skill      # copy kit -> templates/app
make verify-skill    # CI runs this; fails on drift
```

`feature-flow` and the app's `git-flow` are app-only: they live in `templates/` alone, and editing
the kit's `git-flow` does **not** change them. Adding a file to `SHARED_FILES` means promising the
two copies stay identical forever — only do it for a standard, not for prose that differs per repo.

## Verify — rendering is not compiling

`flutter test test/tools` proves substitution and structure. It does **not** prove the output
compiles. Any template change must end with a real generate-and-run:

```bash
flutter test test/tools
make new-app NAME=tmp_check OUT=/tmp/tmp_check EXTRA="--local"
cd /tmp/tmp_check && for e in dev staging prod; do cp .env.example .env.$e; done
make gen && make ci
make feature NAME=probe && make gen && make ci
rm -rf /tmp/tmp_check
```

`--local` points the generated app at this working tree, so it exercises unreleased kit changes.
**Never commit a `--local` app** — its pubspec has an absolute path.

Failures this loop has actually caught: a pubspec asset dir the template didn't ship, a missing
import in a generated test, a dev dependency used only by the smoke test. None of them were visible
from the render tests.

## After changing a template

Update `docs/scaffold.md` if flags or layout changed, add a `## [Unreleased]` CHANGELOG entry (a new
app's starting point is user-facing), and extend `test/tools/scaffold_engine_test.dart` if the change
added a file that must exist or a rule that must hold.
