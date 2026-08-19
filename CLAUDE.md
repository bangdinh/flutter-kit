# Flutter Kit — Claude Code Instructions

## Project overview
A reusable Flutter template using **Feature-first Clean Architecture** + **Riverpod 3.x**.

## Architecture rules

### Layer dependencies (strict)
- `domain/` → depends on NOTHING (pure Dart, no Flutter imports)
- `data/` → depends on `domain/` only
- `presentation/` → depends on `domain/` and reads `data/` through Riverpod providers
- `core/` → shared infrastructure, any layer can use it
- `shared/` → shared widgets/models, any layer can use it

### Feature structure
Every feature follows this structure — use `features/auth/` as the reference:
```
features/<name>/
├── data/
│   ├── datasources/    ← HTTP calls (Dio)
│   ├── models/         ← DTOs with fromJson/toEntity (freezed)
│   └── repositories/   ← Implements domain contract
├── domain/
│   ├── entities/       ← Pure business objects (freezed, NO json)
│   └── repositories/   ← Abstract contracts
└── presentation/
    ├── providers/      ← Riverpod providers (@riverpod annotation)
    ├── pages/          ← Screen widgets
    └── widgets/        ← Feature-specific widgets
```

Create new features with: `make feature NAME=<name>`

### State management — Riverpod 3.x
- Use `@riverpod` annotation + code generation (NOT hand-written providers)
- Functional providers use `Ref` (NOT specific `XxxRef` types — those were Riverpod 2.x)
- Generated provider names drop "Notifier": class `AuthStateNotifier` → `authStateProvider`
- Use `ref.watch()` in widgets for reactive rebuilds
- Use `ref.read()` for one-shot actions (button taps)
- Use `ref.listen()` for side effects — `prev` parameter is nullable
- Use `AsyncValue.guard()` for async operations in notifiers
- `AsyncValue.value` is nullable (replaces old `valueOrNull`)
- All notifiers auto-dispose by default; use `@Riverpod(keepAlive: true)` to persist
- Riverpod IS the DI container — do NOT add get_it or injectable

### Models
- Domain entities: `@freezed abstract class` — NO json, NO framework imports
- Data models: `@freezed abstract class` with `fromJson` + `toEntity()` method
- Use `const factory` constructors

### Error handling
- API errors flow through interceptors → `ApiException` (sealed class)
- Use `apiCall()` wrapper from `core/network/helpers/` for Result-based handling
- Use `AsyncValue` pattern for loading/error/data in UI
- Map exceptions to user messages with `apiExceptionToMessage()`

### Naming conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `@riverpod` generates `<className>Provider` automatically
- Notifier classes: generated name drops "Notifier" suffix
- Repositories: abstract in `domain/`, impl suffixed `_impl` in `data/`
- Data sources: suffixed `_remote_data_source` or `_local_data_source`

## Common commands
```bash
make get          # flutter pub get
make gen          # build_runner (freezed, riverpod, json)
make gen-watch    # build_runner watch mode
make clean        # flutter clean + pub get
make analyze      # flutter analyze
make test         # flutter test
make format       # dart format
make feature NAME=profile   # scaffold new feature
make rename NAME=my_app     # fork kit with new name
make ci           # run full CI locally
```

## Key files
- `lib/main.dart` — entry point (1 line)
- `lib/bootstrap.dart` — ProviderScope + async init
- `lib/app/env/app_env.dart` — API URLs per environment
- `lib/app/theme/app_colors.dart` — color palette (change to rebrand)
- `lib/core/network/api_client.dart` — Dio provider with interceptor stack
- `lib/shared/models/result.dart` — sealed Result<T> type

## Testing patterns
- Override Riverpod providers with fakes — see `test/features/auth/`
- Use `ProviderContainer` for unit-testing providers
- Use `ProviderScope(overrides: [...])` + `MaterialApp` for widget tests
- Fake repositories go in `test/<feature>/data/fake_<name>_repository.dart`

## SDK & flutter analyze
- SDK constraint: `^3.7.0`
- `flutter analyze` may crash on this machine due to Homebrew dart conflict
- Use: `/Users/bangs/development/flutter/bin/dart analyze lib/` instead

## Do NOT
- Add `get_it` or `injectable` — Riverpod handles DI
- Use `XxxRef` types in functional providers — use `Ref` (Riverpod 3.x)
- Use `valueOrNull` on AsyncValue — use `value` (nullable in Riverpod 3.x)
- Import Flutter in domain layer entities
- Put business logic in widgets — use providers
- Create barrel exports per feature — only `core/core.dart` and `shared/shared.dart`
- Use `auto_route` — this project uses `go_router`
