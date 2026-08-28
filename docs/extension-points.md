# Extension points

Every kit behaviour an app might need to change is a **provider you override** — not a fork, not a
subclass of a kit widget, not a flag inside the kit.

| Provider | Default | Override to… |
|---|---|---|
| `kitConfigProvider` | throws | supply base URL, timeouts, retries, headers (done by `bootstrapKit`) |
| `tokenStoreProvider` | `SecureTokenStore` | keep credentials somewhere else (cookie, in-memory, OAuth lib) |
| `tokenRefresherProvider` | `null` | refresh an expired token and replay the request |
| `unauthorizedHandlerProvider` | `null` | react to lost auth (clear session, route to login) |
| `extraInterceptorsProvider` | `[]` | add tracing/tenant/signing interceptors after the kit's stack |
| `apiErrorMessagesProvider` | English defaults | localize or reword user-facing error copy |
| `localStorageProvider` | overridden by `bootstrapKit` | inject a fake `SharedPreferences` in tests |

Two more extension points aren't providers, because they're per-call values:

- **Theme** — `KitTheme.light(KitColors(...))`, then `.copyWith(...)` for anything the tokens don't
  cover. See [theme.md](theme.md).
- **Router** — the app builds its own `GoRouter` and passes it to `KitApp(routerConfig: ...)`. The
  kit has no route table and no opinion about redirects.

## Wiring them

```dart
Future<void> bootstrap() {
  return bootstrapKit(
    config: KitConfig(apiBaseUrl: Env.apiBaseUrl, envLabel: 'DEV'),
    appBuilder: () => const MyApp(),
    overrides: [
      tokenRefresherProvider.overrideWithValue(_refreshAccessToken),
      unauthorizedHandlerProvider.overrideWithValue(_logout),
      apiErrorMessagesProvider.overrideWithValue(const ViErrorMessages()),
      extraInterceptorsProvider.overrideWithValue([TenantInterceptor()]),
    ],
  );
}
```

## Adding a new one

When the kit genuinely can't express what an app needs:

1. Define the **contract** in the kit (abstract interface, or a typedef for a callback).
2. Ship a **default** that is correct for the common case — never a stub that throws, unless the
   app *must* supply it (`kitConfigProvider` is the only such case).
3. Expose it as a `@Riverpod(keepAlive: true)` provider so an app overrides it in one line.
4. Test both sides: the default behaviour, and that an override wins
   (`test/network/api_client_test.dart` is the pattern).
5. Document it in the table above and add a `CHANGELOG.md` entry under `## [Unreleased]`.

What not to do: an `if (appName == ...)` inside the kit, a copy of a kit file inside an app, or a
kit dependency added for one app's need.
