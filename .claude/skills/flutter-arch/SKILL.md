---
name: flutter-arch
description: Use when writing, reviewing or restructuring Dart/Flutter code in flutter-kit or in an app built on it — where a file belongs, layer dependency rules, Riverpod 3.x providers, freezed models, error/Result contract, theming. Trigger khi "thêm feature", "tạo provider", "review code Flutter", "kiến trúc Flutter", "đặt file ở đâu", "sửa theme", "gọi API", "viết widget".
---

# flutter-arch (flutter_kit — Feature-first Clean Architecture + Riverpod 3.x)

Full reference: `docs/architecture.md`, `docs/network.md`, `docs/state.md`. This skill is the
checklist that keeps code correct without reading them.

## Rule 0 — kit or app?

| Goes in the **kit** (`lib/src/`) | Goes in the **app** |
|---|---|
| Anything ≥2 apps would copy verbatim | Anything that encodes a product decision |
| Contracts + defaults (`TokenStore`, `ApiErrorMessages`, `KitColors`) | Implementations of those contracts |
| Transport plumbing, `Result`, pagination, theme *shapes* | Routes, features, env resolution, palette *values*, copy |

Before adding to the kit, ask: *would a second app want this unchanged?* If it needs an `if` on
the app name, an endpoint path, or product wording — it's an app rule. Designing the seam for it
(contract + default + overridable provider) is the **kit-extension-point** skill's scope.

## Layer dependencies (strict, enforced by review)

```
domain/      → nothing (pure Dart; NO flutter, NO dio, NO json)
data/        → domain + package:flutter_kit
presentation/→ domain (+ data only through Riverpod providers)
```
A `flutter` or `dio` import inside `domain/` is a defect. So is a widget importing a
`*_remote_data_source.dart` directly.

## Feature structure (one feature = one folder)

```
features/<name>/
├── data/{datasources,models,repositories}/
├── domain/{entities,repositories}/
└── presentation/{providers,pages,widgets}/
```

- `domain/entities/` — `@freezed abstract class`, no `fromJson`.
- `data/models/` — `@freezed abstract class` with `fromJson` **and** `toEntity()`. DTO ≠ entity.
- `domain/repositories/` — abstract contract; impl in `data/repositories/` suffixed `_impl`.
- Datasources own URLs + JSON only. Repositories own error mapping (`apiCall`) and persistence.
- No barrel file per feature. The kit's `flutter_kit.dart` is the only barrel.

## Network — the kit owns the stack **and** the b2b-gokit contract

- Get Dio from `ref.watch(apiClientProvider)` — never `Dio()`. Base URL/timeouts/headers come
  from `KitConfig`; don't set them per call.
- **Unwrap with `ApiData` / `ApiPage`**, never `response.data['data']` by hand. Success is
  `{"data": ...}` (+ `page` for collections); there is no `success`/`message`/`status` field.
- **Pagination is by opaque cursor**, not page number: `fetchPage(String? cursor)` →
  `ApiPage<T>`, echo `nextCursor` back untouched, trust `hasMore` (a short page ≠ the end).
  `total` is optional — never require it in UI.
- Repositories return `Result<T>` via `apiCall(() async {...})`; presentation never sees
  `DioException`. Errors arrive as sealed `ApiException` subtypes carrying gokit's stable
  `code`, plus `traceId`.
- **Switch on `code`, not on `status`** — `CONFLICT` and `ALREADY_EXISTS` are both 409.
- User-facing wording: `ref.read(apiErrorMessagesProvider).message(e)`, not a hand-written string,
  and never the server's `detail` or `traceId`. Log the trace id; show it to no one.
- Form errors: `ValidationException.reasonFor('email')` — the server's `errors[]`.
- Need a header/tracing/tenant rule? Override `extraInterceptorsProvider`. Don't fork the kit stack.
- Auth: implement `TokenStore` / override `tokenRefresherProvider` / `unauthorizedHandlerProvider`.
  Never read secure storage from a widget or a datasource.
- `Options(extra: {'skip_auth': true})` for endpoints that must not carry a token (login, refresh).

## State — Riverpod 3.x (it IS the DI container; never add get_it/injectable)

- `@riverpod` + codegen only. No hand-written `Provider(...)` in feature code.
- Functional providers take `Ref` (not `XxxRef` — that was Riverpod 2.x).
- Generated name drops `Notifier`: `class AuthStateNotifier` → `authStateProvider`.
- `ref.watch` in `build`, `ref.read` for one-shot actions, `ref.listen` for side effects
  (`prev` is nullable). Async mutations go through `AsyncValue.guard`.
- `AsyncValue.value` is nullable — there is no `valueOrNull`.
- Auto-dispose is the default; `@Riverpod(keepAlive: true)` only for app-lifetime singletons.
- Async dependencies are resolved in `bootstrapKit` and injected as overrides — do not introduce a
  `FutureProvider` for something already available synchronously.

## UI & theme

- Spacing/radii from `AppSizes`; colors from `Theme.of(context).colorScheme`. No magic numbers,
  no raw `Color(0x...)` in a widget.
- Rebrand by passing `KitColors` to `KitTheme.light/dark`, then `.copyWith` for the rest.
  Never fork `kit_theme.dart` into an app.
- Reuse `AppButton`, `AppTextField`, `AppCachedImage`, `AsyncValueWidget`, `PaginatedListView`
  before writing a new widget. Business logic lives in providers, not widgets.
- `KitApp` runs edge-to-edge and owns the system-bar style (`kitSystemUiOverlayStyle`) — never call
  `SystemChrome.setSystemUIOverlayStyle` in a page. But the kit does not inset your layout: any
  full-bleed page (`Stack`, custom scroll view) needs `SafeArea`, or content hides under the bars on
  API 35+.

## Verify — exact commands

```bash
dart run build_runner build        # regenerate after touching @riverpod/@freezed/@Envied
dart analyze lib test              # `flutter analyze` crashes on some machines — see CLAUDE.md
flutter test
```
Chain them with `&&`. In the kit, run them at the root **and** in `example/` — they are separate
packages, and `build.yaml` deliberately keeps the kit's codegen out of `example/`.

## TDD

Write the failing test first (red → green → refactor). How to test — fakes, `ProviderContainer`
setup, the Riverpod 3 traps that hang a test — is the **flutter-testing** skill's scope.

## Never

- Put an app's rule in the kit (endpoint path, product copy, brand value, feature flag).
- Import `package:flutter_kit/src/...` from an app — only the `flutter_kit.dart` barrel is public API.
- Add a dependency to the kit for a single app's need.
- Widen the kit's public API without a doc + CHANGELOG entry (see git-flow for the version bump).
