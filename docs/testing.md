# Testing

TDD: write the failing test first (red → green → refactor). A new kit extension point isn't done
until a test proves the default **and** that an app override wins.

## Unit-testing a provider

```dart
final container = ProviderContainer(
  overrides: [kitConfigProvider.overrideWithValue(const KitConfig(apiBaseUrl: 'https://x'))],
);
addTearDown(container.dispose);

expect(container.read(apiClientProvider).options.baseUrl, 'https://x');
```

Two traps in this snippet, both Riverpod 3 defaults:

- **Retry** — a bare `ProviderContainer` retries a throwing provider 10 times with backoff, so an
  error-path test hangs to the timeout. Pass `retry: (_, _) => null`.
- **Auto-dispose** — reading `provider.future` alone opens a subscription that closes immediately
  and the provider is disposed mid-load ("disposed during loading state"). Hold a listener open:
  `final sub = container.listen(provider, (_, _) {}); addTearDown(sub.close);`

Awaiting `.future` surfaces your own exception; a *synchronous* `container.read` hands you a
`ProviderException` wrapping it. Assert accordingly.

`Override` and `ProviderException` are not in `flutter_riverpod.dart`'s export list — import
`package:flutter_riverpod/misc.dart show Override, ProviderException` when you need to name them.

## Fake repositories, not mocked HTTP

Override the repository provider with a fake that implements the domain contract — the test then
exercises real notifier logic with no Dio, no server, no timing:

```dart
class FakeAuthRepository implements AuthRepository { ... }

ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
  child: const MaterialApp(home: LoginPage()),
);
```

Fakes live in `test/features/<feature>/data/fake_<name>_repository.dart`.

## Widget tests

Wrap in `ProviderScope(overrides: [...])` + `MaterialApp`. For anything reading
`localStorageProvider`, override it with `SharedPreferences.setMockInitialValues({})`-backed
instance rather than booting the app.

## Commands

```bash
dart analyze lib test && flutter test              # the kit
(cd example && dart analyze lib test && flutter test)  # the example app
make ci                                            # both, exactly what CI runs
```

Generated code is committed, so `build_runner` should be a no-op on a clean checkout; if it writes
something, the annotation change behind it was never committed.

`flutter analyze` crashes on some machines (Homebrew dart on PATH ahead of the SDK's) — the kit
standardises on `dart analyze`, in the Makefile and in CI.
