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

`flutter analyze` crashes on some machines (Homebrew dart on PATH ahead of the SDK's) — the kit
standardises on `dart analyze`, in the Makefile and in CI.
