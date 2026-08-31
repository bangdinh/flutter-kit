---
name: flutter-testing
description: Use when writing, fixing or reviewing tests in flutter-kit or an app built on it — unit tests for providers/notifiers, widget tests, fake repositories, overriding kit providers, and diagnosing a test that hangs, flakes or fails only in CI. Trigger khi "viết test", "test fail", "test treo", "mock", "fake repository", "ProviderContainer", "widget test", "coverage", "TDD".
---

# flutter-testing (flutter_kit + apps on it)

TDD is the rule: failing test first (red → green → refactor). A bug fix starts with a test that
reproduces it; a new kit extension point needs a test for the **default** *and* for an app
**override** winning.

## Commands

```bash
flutter test                      # all
flutter test test/features/x      # one folder
flutter test --coverage           # coverage/lcov.info
```

In the kit, `test/` and `example/test/` are separate packages — run both (`make ci`).

## Riverpod 3 traps — every one of these has cost hours

**A throwing provider is retried 10×.** Riverpod retries any provider whose build throws a
non-`Error` (an `ApiException` counts), 200ms doubling to 6.4s. An error-path test on a bare
`ProviderContainer` therefore hangs until the 30s timeout and reads as "my test is broken".

```dart
final container = ProviderContainer(
  overrides: [...],
  retry: (_, _) => null, // apps get this from bootstrapKit; tests must ask
);
```

**Reading `.future` alone kills the provider.** `container.read(p.future)` opens a subscription that
closes immediately, so an auto-dispose provider is disposed mid-load →
*"disposed during loading state, yet no value could be emitted"*. Hold a listener:

```dart
final sub = container.listen(provider, (_, _) {});
addTearDown(sub.close);
```

**Error type depends on how you read.** `await container.read(p.future)` throws *your* exception;
a synchronous `container.read(p)` throws a `ProviderException` wrapping it —
`isA<ProviderException>().having((e) => e.exception, 'exception', isUnimplementedError)`.

**Imports.** `Override` and `ProviderException` are not exported by `flutter_riverpod.dart`:
`import 'package:flutter_riverpod/misc.dart' show Override, ProviderException;`

Always `addTearDown(container.dispose)`.

## Fake repositories, never mocked HTTP

Implement the domain contract in memory and override the repository provider. The test then
exercises real notifier logic with no Dio, no server, no timing:

```dart
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.failure, List<Profile>? items}) : items = items ?? const [];
  final ApiException? failure;   // set to drive the error path
  final List<Profile> items;
  ...
}
```

Location: `test/features/<feature>/data/fake_<name>_repository.dart` — `make feature` generates one.
No mocking package: a fake that implements the contract fails to compile when the contract changes;
a mock keeps compiling and lies.

Test HTTP-level behaviour (interceptors, error mapping) against `Dio` directly, not through a
feature — see `test/network/` in the kit.

## Widget tests

```dart
SharedPreferences.setMockInitialValues({});
final prefs = await SharedPreferences.getInstance();

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(prefs), // bootstrapKit does this in prod
      profileRepositoryProvider.overrideWithValue(fake),
    ],
    child: const MaterialApp(home: ProfilePage()),
  ),
);
await tester.pumpAndSettle();
```

- Anything reading `localStorageProvider` (theme mode, `KitApp`) needs that override or it throws.
- `kitConfigProvider` throws by design until overridden — that is the failure you want when an app
  forgets to boot through `bootstrapKit`.
- `pumpAndSettle` after an async provider; a bare `pump` shows the loading frame.
- Assert on user-visible text/semantics, not widget internals.

## What to test, and what not to

| Test | Don't bother |
|---|---|
| notifier logic: success, failure, refresh, empty | that Riverpod calls `build` |
| repository mapping DTO → entity, `Result` on error | freezed `copyWith`/`==` |
| interceptor/error-mapping behaviour in the kit | generated `.g.dart` code |
| a widget's states (loading/error/data, validation) | exact padding values |
| every kit extension point: default **and** override | third-party packages |

A test that only re-states the implementation line by line is churn — it fails on every refactor and
catches nothing.

## When a test fails only in CI

Check, in order: generated code not committed (CI regenerates and diffs) · `.env.*` missing (CI
seeds placeholders) · reliance on wall-clock or ordering · a real dependency left un-overridden, so
the test hit the network locally by luck and not in CI.
