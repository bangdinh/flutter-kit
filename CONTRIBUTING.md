# Contributing to flutter_kit

This is a base library other apps depend on by pinned tag. A mistake here doesn't break one screen,
it breaks every app on the next bump — so the bar is correctness, not velocity.

## Setup

```bash
make get                       # pub get for the kit and example/
cd example && for e in dev staging prod; do echo "API_BASE_URL=https://api.example.com" > .env.$e; done
make gen && make gen-example   # code generation (generated files are gitignored)
make ci                        # analyze + test, kit + example
```

Requires Flutter `3.41.x` (Dart `3.11`). Use `dart analyze`, not `flutter analyze` — the analysis
server crashes on some machines and CI uses `dart analyze` for the same reason.

## The one design question

**Would a second app want this unchanged?**

- Yes → it belongs in the kit.
- No → it's an app rule. Add an *extension point* to the kit (a contract, a sane default, an
  overridable provider) and let the app decide. Never an `if` on an app name, an endpoint path, or
  product wording inside `lib/src/`.

See `docs/extension-points.md` for the pattern and the existing list.

## Layer rules (reviewed on every PR)

| Layer | May depend on |
|---|---|
| `domain/` | nothing — pure Dart. No `flutter`, no `dio`, no JSON |
| `data/` | `domain/` + `package:flutter_kit` |
| `presentation/` | `domain/`, and `data/` only through Riverpod providers |

`lib/src/**` is private. A new public symbol must be exported from `lib/flutter_kit.dart`,
documented in `docs/`, and listed under `## [Unreleased]` in `CHANGELOG.md`.

## TDD

Write the failing test first (red → green → refactor). Specifically:

- A new extension point needs a test for the **default** behaviour *and* one proving an **override**
  wins — see `test/network/api_client_test.dart`.
- A bug fix starts with a test that reproduces it.
- Feature-level logic is tested against a **fake repository**, not mocked HTTP (`docs/testing.md`).

## Git flow

Trunk-based on `master`.

1. Branch from up-to-date `master`: `<type>/<brief-3-words>` — `type` ∈
   `feature|bugfix|refactor|chore|docs|spike`. With a ticket: `feature/B2B-123-token-refresh`.
2. Conventional commits: `<type>(<scope>): <summary>` — `type` ∈
   `feat|fix|refactor|test|docs|chore|perf|ci`; `scope` ∈ `network|theme|app|storage|ui|example|docs|skills`.
   Breaking public API → `feat(network)!: ...`. No `wip`, `fix bug`, `update code`.
3. Small, single-purpose commits. Never push straight to `master` — always a PR.
4. Secrets never enter a commit: no `.env.*`, keystores, tokens, debug logs. Only `*.example`.

Claude Code (and any agent) **proposes** git commands; a human runs `commit`, `push` and `tag`.

## PR checklist

```bash
make ci   # kit + example: codegen, dart analyze, tests
```

Plus:

- [ ] Public API change → `docs/` updated and `CHANGELOG.md` `## [Unreleased]` entry added
- [ ] Hard-to-reverse decision → ADR under `docs/adr/`
- [ ] No secret, no leftover debug logging, no `TODO` without an owner
- [ ] No `dependency_overrides` or `path:` kit dependency committed outside `example/`
- [ ] Behaviour change in the kit → `example/` still analyzes and passes tests (CI enforces this,
      because it's the only consumer we can see)

## Release (maintainer)

```bash
make release VERSION=v0.2.0 DRY=1   # preview the CHANGELOG entry
make release VERSION=v0.2.0         # CHANGELOG + commit + annotated tag, no push
git push origin master --tags       # a human runs this
```

Pre-1.0: MINOR for a feature *or* a breaking change, PATCH for a compatible fix. **Never re-tag a
published version** — it poisons the `pub` cache of every app pinning it; ship a new patch instead.
