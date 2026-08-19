# Flutter Kit

A reusable Flutter project template with **Feature-first Clean Architecture** + **Riverpod**.

Based on [Andrea Bizzotto's Flutter Tips](https://github.com/bizz84/flutter-tips-and-tricks) and proven patterns from production apps.

## Tech Stack

| Concern | Solution |
|---|---|
| State Management + DI | **Riverpod** (flutter_riverpod + riverpod_generator) |
| Router | **GoRouter** (official Flutter navigation) |
| Network | **Dio** (interceptor-based HTTP client) |
| Models | **Freezed** + json_serializable |
| Storage | SharedPreferences + FlutterSecureStorage |
| Linting | flutter_lints + riverpod_lint |

## Architecture

```
lib/
├── main.dart                          ← Entry point
├── bootstrap.dart                     ← App initialization + ProviderScope
├── app/
│   ├── app.dart                       ← Root ConsumerWidget
│   ├── router/                        ← GoRouter config + route paths
│   ├── theme/                         ← AppTheme (light/dark) + AppColors
│   └── env/                           ← Environment config (dev/stg/prod)
├── core/
│   ├── network/
│   │   ├── api_client.dart            ← Dio provider
│   │   ├── interceptors/              ← Auth, Error, Logging
│   │   ├── errors/                    ← ApiException sealed class
│   │   └── models/                    ← ApiResponse, PaginatedResponse
│   ├── storage/                       ← SecureStorage, LocalStorage providers
│   ├── extensions/                    ← BuildContext, String extensions
│   └── logging/                       ← AppLogger
├── features/
│   └── auth/                          ← Sample feature (use as template)
│       ├── data/
│       │   ├── datasources/           ← HTTP calls
│       │   ├── models/                ← DTOs (freezed + json)
│       │   └── repositories/          ← Repository implementation
│       ├── domain/
│       │   ├── entities/              ← Pure business objects (freezed)
│       │   └── repositories/          ← Abstract contracts
│       └── presentation/
│           ├── providers/             ← Riverpod providers (state)
│           ├── pages/                 ← Screen widgets
│           └── widgets/               ← Feature-specific widgets
└── shared/
    ├── widgets/                       ← Reusable UI components
    ├── models/                        ← Result type, shared models
    └── constants/                     ← AppSizes, spacing tokens
```

## Tips Applied

| # | Tip | Where |
|---|---|---|
| #21 | Repositories as abstract classes | `domain/repositories/` |
| #28 | DDD — Domain Model | `domain/entities/` |
| #29 | Domain-driven exception handling | `core/network/errors/` |
| #32 | Use composition aggressively | Widgets, extensions |
| #37 | Rules for good app architecture | Overall structure |
| #39 | Feature-first project structure | `features/` |
| #40 | Anatomy of a Riverpod Provider | All providers |
| #41 | Fake repositories for testing | Repository pattern |
| #44 | AsyncValue.guard vs try-catch | `auth_provider.dart` |
| #46 | ref.watch vs ref.read vs ref.listen | `login_form.dart` |
| #56 | Async init with provider overrides | `bootstrap.dart` |
| #62 | try-catch & Result type | `shared/models/result.dart` |
| #72 | Type annotations for safer code | Strict analysis rules |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.7.0
- Dart >= 3.7.0

### Setup

```bash
# Install dependencies
make get

# Run code generation (freezed, riverpod_generator, json_serializable)
make gen

# Run the app
make run-dev
```

### Create a New Feature

```bash
make feature NAME=profile
```

This creates the full feature folder structure. Use `features/auth/` as reference.

### Useful Commands

```bash
make gen          # One-time code generation
make gen-watch    # Watch mode for code generation
make clean        # Clean and re-fetch dependencies
make analyze      # Run static analysis
make format       # Format code
make test         # Run tests
```

## Key Patterns

### Riverpod as DI + State Management

No `get_it` needed — Riverpod providers ARE the DI container:

```dart
// Define
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
}

// Use in widget
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    return authState.when(
      data: (state) => Text('Hello ${state.user?.name}'),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}
```

### Result Type for Explicit Error Handling

```dart
final result = await repo.login(email, password);
switch (result) {
  case Success(:final data):
    // handle user
  case Failure(:final exception):
    // handle error
}
```

## Rebranding

To use this kit for a new project:

1. Change `name` in `pubspec.yaml`
2. Update colors in `app/theme/app_colors.dart`
3. Update API base URLs in `app/env/app_env.dart`
4. Replace the sample `auth` feature or use it as-is
