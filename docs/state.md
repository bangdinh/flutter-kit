# State — Riverpod 3.x

Riverpod **is** the DI container. Adding `get_it` or `injectable` on top means two containers with
two lifetimes and no compile-time link between them — don't.

## Rules that bite if ignored (3.x changed these)

- Functional providers take `Ref`, not a generated `XxxRef` type (that was 2.x).
- The generated provider name drops `Notifier`: `class AuthStateNotifier` → `authStateProvider`.
- `AsyncValue.value` is nullable; `valueOrNull` is gone.
- A provider's thrown error reaches `container.read` wrapped in a `ProviderException` — assert on
  `.exception` in tests.
- Auto-dispose is the default. `@Riverpod(keepAlive: true)` only for app-lifetime singletons
  (config, storage, the Dio client).
- Everything is code-generated: `@riverpod` + `dart run build_runner build`. No hand-written
  `Provider(...)` in feature code.

## Which ref method

| Use | For |
|---|---|
| `ref.watch` | inside `build` — rebuild when the dependency changes |
| `ref.read` | one-shot actions (button taps, notifier methods) |
| `ref.listen` | side effects: snackbars, navigation (`prev` is nullable) |

Async mutations go through `AsyncValue.guard` so a thrown error lands in the state instead of an
unhandled zone error:

```dart
Future<void> login({required String email, required String password}) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final user = await ref.read(authRepositoryProvider).login(email: email, password: password);
    return AuthState(user: user, isLoggedIn: true);
  });
}
```

## Async dependencies are resolved before `runApp`

`bootstrapKit` awaits `SharedPreferences` and injects it as an override, so `localStorageProvider`
is synchronous everywhere. Do the same for your own async singletons — pass them through
`bootstrapKit(overrides: [...])` rather than introducing a `FutureProvider` and an `AsyncValue`
into every consumer.

## App lifecycle

`appLifecycleProvider` exposes `AppLifecycleState` as a provider:

```dart
ref.listen(appLifecycleProvider, (prev, next) {
  if (next == AppLifecycleState.resumed) ref.invalidate(dashboardProvider);
});
```

## Theme mode

`themeModeProvider` persists `system`/`light`/`dark` to `SharedPreferences`; `KitApp` reads it.
Toggle with `ref.read(themeModeProvider.notifier).toggleTheme()`.
