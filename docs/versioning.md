# Versioning

## What is promised

Only what `lib/flutter_kit.dart` exports. `lib/src/**` is private: an app importing
`package:flutter_kit/src/...` is relying on something that can change in a patch release.

## SemVer, pre-1.0

| Bump | For |
|---|---|
| **MINOR** (`v0.1.0` → `v0.2.0`) | new feature **or** a breaking change to public API |
| **PATCH** (`v0.1.0` → `v0.1.1`) | backwards-compatible fix |

After `v1.0.0`, breaking changes become MAJOR.

## Releasing (maintainer)

```bash
make release VERSION=v0.2.0 DRY=1   # preview the generated CHANGELOG entry
make release VERSION=v0.2.0         # CHANGELOG + commit + annotated tag (no push)
git push origin master --tags       # you run this
```

`scripts/release.sh` builds the entry from conventional commits in `prev-tag..HEAD`, guards on
branch `master` + a clean tree, and puts the release notes inside the annotated tag.

**Never re-tag a pushed version** — it poisons the `pub` cache of every app that already resolved
it, in a way that looks like a random build failure. Ship a new patch instead.

Generated code is committed and must be regenerated before tagging: a consumer resolving the tag
from git gets exactly what's in the tree, and `build_runner` never runs on a dependency. A tag with
stale `.g.dart` is a broken tag you cannot fix in place — CI's staleness check is what keeps that
from happening.

## Consuming (apps)

```yaml
dependencies:
  flutter_kit:
    git:
      url: git@github.com:bangdinh/flutter-kit.git
      ref: v0.2.0 # exact tag, never a branch
```

Working on kit and app together? Use an **uncommitted** `pubspec_overrides.yaml` in the app:

```yaml
dependency_overrides:
  flutter_kit:
    path: ../flutter-kit
```

Committing a `path:` dependency (or a `dependency_overrides` block) to an app is how a release
ends up shipping an unreleased kit. `example/` is the one legitimate exception — it is part of this
repo and must track the working tree.
