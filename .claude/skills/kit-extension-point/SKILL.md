---
name: kit-extension-point
description: Use when an app needs behaviour flutter_kit doesn't offer, or when reviewing whether something belongs in the kit or in the app — designing a contract + default + overridable provider instead of forking, branching on an app name, or copying kit code. Kit repo, or an app asking the kit for something. Trigger khi "kit thiếu", "thêm vào kit", "app cần override", "nên để ở kit hay app", "custom lại của kit", "fork".
---

# kit-extension-point

The kit is a library other apps pin by tag. Every app-specific `if` inside it is paid for by every
other app, forever. So the kit never learns about an app — it grows a seam the app fills.

## The decision

> **Would a second app want this unchanged?**

- **Yes** → it belongs in the kit as behaviour.
- **No** → it's an app rule. The kit gets an *extension point*; the app supplies the value.

Signals it is an app rule: an endpoint path, product wording, a brand value, a feature flag, a
tenant, anything named after one app. Signals it belongs in the kit: two apps have written the same
workaround; or the app had to reach into `package:flutter_kit/src/...` to do it.

## Never do these instead

| Anti-pattern | Why it fails |
|---|---|
| A second `Dio` in the app | loses auth, retry, the error contract — silently, at runtime |
| Copying `kit_theme.dart` / a kit widget into the app | kit fixes stop arriving; two apps drift |
| `import 'package:flutter_kit/src/...'` | private half, changes in a patch release |
| `if (appName == 'x')` inside the kit | every app pays; untestable; multiplies |
| A `dependency_overrides` pointing at a local kit | ships an unreleased kit to production |

## The shape (all five parts, or it isn't done)

1. **Contract** — an `abstract interface class` for a collaborator (`TokenStore`), or a `typedef` for
   a callback (`TokenRefresher`, `ProviderRetry`).
2. **Default** — correct for the common case, shipped by the kit (`SecureTokenStore`,
   `ApiErrorMessages`, `kitNoProviderRetry`). Throw-by-default only when the app *must* decide —
   `kitConfigProvider` is the single case, and its message names the fix.
3. **Provider** — `@Riverpod(keepAlive: true)` so an app overrides it in one line, in
   `bootstrapKit(overrides: [...])`. Per-call values (theme tokens, `routerConfig`) are parameters
   instead, not providers.
4. **Tests** — the default behaves, *and* an override wins. `test/network/api_client_test.dart` is
   the pattern.
5. **Docs** — a row in `docs/extension-points.md`, and a `## [Unreleased]` entry in `CHANGELOG.md`.

```dart
typedef TokenRefresher = Future<bool> Function();

@Riverpod(keepAlive: true)
TokenRefresher? tokenRefresher(Ref ref) => null; // no refresh unless the app says so
```

## Naming and defaults

- Name after the decision, not the app: `apiErrorMessagesProvider`, not `vnMessagesProvider`.
- A `null` default means "feature off" and must be safe. A non-null default must be the choice most
  apps would make anyway.
- Adding an extension point is backwards compatible. **Changing a default is not** — it silently
  changes behaviour on the next `ref:` bump, so it needs a MINOR bump pre-1.0 and a CHANGELOG entry
  under **Breaking**.

## Existing seams — check before inventing one

`kitConfigProvider` · `tokenStoreProvider` · `tokenRefresherProvider` ·
`unauthorizedHandlerProvider` · `extraInterceptorsProvider` · `apiErrorMessagesProvider` ·
`localStorageProvider` · `KitApp(theme:/darkTheme:/routerConfig:/builder:/edgeToEdge:)` ·
`bootstrapKit(overrides:/onInit:/onError:/providerRetry:/orientations:)` ·
`KitTheme.light(KitColors(...)).copyWith(...)` · `Options(extra: {'skip_auth': true})`.

If one of these nearly fits, widen it rather than adding a parallel one — two seams for the same
decision is how a framework becomes unlearnable.

## If the app can't wait

Unblock the app with a local implementation **of the kit's contract** (its own `TokenStore`, its own
`Interceptor`) — never a fork of kit code. Then land the seam in the kit and delete nothing but the
override.
