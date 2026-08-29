# Contributing to __name__

## Setup

```bash
cp .env.example .env.dev && cp .env.example .env.staging && cp .env.example .env.prod
make get && make gen && make ci
```

Use `dart analyze`, not `flutter analyze` (the analysis server crashes on some machines; the
Makefile and CI use `dart analyze`).

## Where code goes

```
lib/features/<name>/
├── data/{datasources,models,repositories}/
├── domain/{entities,repositories}/
└── presentation/{providers,pages,widgets}/
```

| Layer | May depend on |
|---|---|
| `domain/` | nothing — pure Dart. No `flutter`, no `dio`, no JSON |
| `data/` | `domain/` + `package:flutter_kit` |
| `presentation/` | `domain/`, and `data/` only through Riverpod providers |

Create features with `make feature NAME=<name>` — never by hand, so every app on the kit keeps the
same shape. Order of work is in `.claude/skills/feature-flow/SKILL.md`.

## The kit boundary

`package:flutter_kit/flutter_kit.dart` is the whole public API. Importing
`package:flutter_kit/src/...` is not allowed — it's private and changes without a major bump.

Need behaviour the kit doesn't have? Ask the kit for an **extension point** (contract + default +
overridable provider). Do not work around it with a second `Dio`, a copied theme file, or forked kit
code — that is how apps drift apart and stop benefiting from kit fixes.

## TDD

Write the failing test first. Feature logic is tested against a **fake repository** implementing the
domain contract (`test/features/<name>/data/fake_<name>_repository.dart`) — not mocked HTTP. Widget
tests wrap the page in `ProviderScope(overrides: [...])`.

## Git flow

Trunk-based on `master`.

1. Branch from up-to-date `master`: `<type>/<brief-3-words>`, `type` ∈
   `feature|bugfix|hotfix|refactor|chore|docs|spike`. With a ticket: `feature/B2B-123-profile-page`.
2. Conventional commits: `<type>(<scope>): <summary>`, `scope` = feature or area.
3. Never push to `master` — always a PR.
4. **Generated code is committed** (`.g.dart`, `.freezed.dart`): run `make gen` and include it.
5. **Never commit**: `.env`/`.env.*` (only `.env.example`), `env.g.dart`, `*.jks`/`*.keystore`,
   `key.properties`, `google-services.json`, `GoogleService-Info.plist`, tokens, debug logs.

Agents propose git commands; a human runs `commit`, `push`, `tag`.

## PR checklist

```bash
make ci
```

- [ ] `make gen` run and generated files committed (CI fails on a stale diff)
- [ ] No secret, no leftover debug logging
- [ ] API contract changed → docs/collection updated
- [ ] Kit `ref:` bump, if any, is its own commit and the kit CHANGELOG was read

CI runs on PRs into `master` and on manual dispatch — on a feature branch, `make ci` is your
pipeline.

## Release

```bash
git tag -a vX.Y.Z -m "vX.Y.Z — <summary>"
git push origin master --tags
```

Note the pinned flutter_kit tag in the release notes — when a production issue shows up, that's the
first thing anyone needs to know.
