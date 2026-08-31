---
name: feature-flow
description: Use when adding, extending or reviewing a feature folder in this app — which files a feature needs, in which order to write them, what belongs in datasource vs repository vs provider vs widget, how to wire a route and a test. Trigger khi "thêm feature", "thêm màn hình", "thêm API mới", "tạo provider cho", "tạo page", "review feature", "đặt file này ở đâu".
---

# feature-flow (this app)

Scaffold first, never by hand:

```bash
make feature NAME=profile        # → lib/features/profile/{data,domain,presentation}
make gen                         # freezed + riverpod for the new files
```

Structure is not a preference here — `flutter-arch` enforces it, and every app on
flutter_kit has the same one so a developer moving between them loses no time.

## Order of work (each step compiles and is testable)

1. **`domain/entities/<name>.dart`** — `@freezed abstract class`, pure Dart. No JSON, no Flutter.
   *What the app means by this thing*, not what the server sends.
2. **`domain/repositories/<name>_repository.dart`** — abstract contract, methods returning
   `Result<T>`. Write this before any HTTP exists; it's what the presentation layer codes against.
3. **`test/features/<name>/data/fake_<name>_repository.dart`** — implement the contract with
   in-memory data. Now the feature is testable with no server.
4. **`data/models/<name>_model.dart`** — `@freezed` DTO with `fromJson` **and** `toEntity()`.
   Wire format only. `@JsonKey(name: 'snake_case')` maps the server's names; the entity keeps ours.
5. **`data/datasources/<name>_remote_data_source.dart`** — URLs and JSON, nothing else. Dio comes
   from `ref.watch(apiClientProvider)` — never `Dio()`. Fix the endpoint the scaffold guessed.
   Unwrap the response with `ApiData<T>.fromJson` / `ApiPage<T>.fromJson` — the API is b2b-gokit
   (`{"data": ...}` + cursor `page`), so never index `response.data['data']` by hand and never
   paginate by page number: `nextCursor` is opaque, `hasMore` is authoritative.
6. **`data/repositories/<name>_repository_impl.dart`** — wraps every call in `apiCall(() async {...})`
   so failures become `Result.failure(ApiException)`. Persistence and mapping live here.
7. **`presentation/providers/<name>_provider.dart`** — `@riverpod`. Mutations through
   `AsyncValue.guard`. No `Dio`, no DTO, no `Map<String, dynamic>` above this line.
8. **`presentation/pages/` + `widgets/`** — `AsyncValueWidget` for load/error/data,
   `PaginatedListView` for lists, `AppButton`/`AppTextField` before writing new widgets.
9. **Route** — add the path to `lib/app/router/route_paths.dart`, the `GoRoute` to `app_router.dart`.
   Redirect logic stays in `app_router.dart`.

## Boundaries that get reviewed

| Layer | May import |
|---|---|
| `domain/` | nothing — pure Dart (a `flutter` or `dio` import here is a defect) |
| `data/` | `domain/` + `package:flutter_kit` |
| `presentation/` | `domain/`, and `data/` only through Riverpod providers |

- A widget importing a `*_remote_data_source.dart` is wrong — go through a provider.
- A DTO leaking into `presentation/` is wrong — `toEntity()` at the repository boundary.
- Error copy in a widget is wrong — `ref.read(apiErrorMessagesProvider).message(e)`. Showing the
  server's `detail` or `traceId` to a user is wrong too; log the trace id instead.
- Branching on an HTTP status is wrong — switch on `ApiException`'s gokit `code`
  (`CONFLICT` and `ALREADY_EXISTS` are both 409). Form errors: `ValidationException.reasonFor(field)`.
- Business logic in a widget is wrong — it belongs in the notifier, where it can be tested.
- No barrel file per feature. Imports inside a feature stay relative.

## Riverpod 3.x specifics that break silently

- `@riverpod` codegen only; functional providers take `Ref` (not `XxxRef` — that was 2.x).
- Generated name drops `Notifier`: `class ProfileNotifier` → `profileProvider`.
- `AsyncValue.value` is nullable; `valueOrNull` no longer exists.
- Auto-dispose is the default — `@Riverpod(keepAlive: true)` only for app-lifetime state.

## Before opening the PR

```bash
make gen && make analyze && make test
```

Generated code (`.g.dart`, `.freezed.dart`) is **committed** — commit it with the feature; CI fails
on a stale diff. Never commit `env.g.dart` or `.env.*`.

## When the kit is in the way

If the feature needs behaviour the kit doesn't offer, do **not** work around it locally with a
second Dio, a copied theme file, or an import of `package:flutter_kit/src/...`. Open an issue on
flutter_kit for an extension point (contract + default + overridable provider) — the kit's
`docs/extension-points.md` describes the shape. Local workarounds are what make apps drift.
