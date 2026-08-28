# Architecture

## Two repos' worth of responsibility, one boundary

```
┌─ flutter_kit (this package) ──────────────────────────────────────────────┐
│ app/      KitApp · bootstrapKit · KitConfig                               │
│ network/  Dio stack: auth → retry → error mapping · TokenStore · Result    │
│ storage/  SharedPreferences + secure storage providers                    │
│ theme/    KitColors tokens · KitTheme shapes · AppSizes                    │
│ ui/       AppButton · AppTextField · AppCachedImage · AsyncValueWidget ·   │
│           PaginatedListView                                               │
│ models/   Result<T> · PaginatedState<T>                                   │
└───────────────────────────────────────────────────────────────────────────┘
                        ▲ contracts + defaults          │ overrides + features
┌─ your app ────────────────────────────────────────────┴───────────────────┐
│ app/      env resolution · GoRouter · brand palette                       │
│ features/ <feature>/{data,domain,presentation}                            │
└───────────────────────────────────────────────────────────────────────────┘
```

The kit is a **library**, not a template you copy. Apps depend on a pinned tag
(`ref: v0.1.0`) and get fixes by bumping it — nothing is forked. See
[adr/0001-library-not-template.md](adr/0001-library-not-template.md).

## Layer dependencies (strict)

| Layer | May depend on |
|---|---|
| `domain/` | nothing — pure Dart. No `flutter`, no `dio`, no `json_annotation` |
| `data/` | `domain/` + `package:flutter_kit` |
| `presentation/` | `domain/`, and `data/` only through Riverpod providers |

A `flutter` import in `domain/` or a widget importing a datasource directly is a defect, not a
style preference: it's what stops a feature from being testable without a device or a server.

## Feature-first, one folder per feature

```
features/<name>/
├── data/
│   ├── datasources/    URLs + JSON. Nothing else.
│   ├── models/         DTOs: @freezed + fromJson + toEntity()
│   └── repositories/   <name>_repository_impl.dart — error mapping, persistence
├── domain/
│   ├── entities/       @freezed, no JSON, no framework
│   └── repositories/   abstract contracts
└── presentation/
    ├── providers/      @riverpod state
    ├── pages/          screens
    └── widgets/        feature-local widgets
```

Why DTO ≠ entity: the wire format is the server's decision and changes on its schedule. Keeping
`UserModel.fromJson` out of `User` means a renamed JSON field touches one file.

No barrel per feature — `flutter_kit.dart` is the only barrel in play. Feature-local imports stay
relative so a moved feature keeps compiling.

## What goes in the kit

Add to the kit only what a second app would want **unchanged**. Anything that encodes a product
decision — an endpoint path, wording, a brand value, a feature flag — is an app rule; the kit gets
an *extension point* for it instead ([extension-points.md](extension-points.md)).

`lib/src/**` is private. Only what `lib/flutter_kit.dart` exports is public API, and only that is
covered by the versioning promise in [versioning.md](versioning.md).
