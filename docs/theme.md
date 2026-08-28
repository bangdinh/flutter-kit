# Theme, spacing, widgets

## Rebrand = pass tokens, don't fork

`KitColors` is the palette shape; `KitTheme` turns it into Material 3 `ThemeData` with the
component decisions an app shouldn't re-litigate (48pt button height, 12pt radii, flat app bar,
filled inputs).

```dart
const brand = KitColors(
  primary: Color(0xFF0F62FE),
  secondary: Color(0xFF6929C4),
  // everything else keeps kit defaults
);

KitApp(
  theme: KitTheme.light(brand),
  darkTheme: KitTheme.dark(brand),
  ...
);
```

Need more than the tokens allow? `KitTheme.light(brand).copyWith(chipTheme: ...)`. Copying
`kit_theme.dart` into an app is how two apps silently drift apart — and how a kit fix stops
reaching either.

## Edge-to-edge system bars

`KitApp` opts into `SystemUiMode.edgeToEdge` and annotates every frame with
`kitSystemUiOverlayStyle(Theme.of(context).brightness)`: transparent status and navigation bars,
with icon brightness inverted against the resolved theme. Switching light↔dark keeps the icons
legible without any app code.

Why the kit opts in rather than leaving it: Android **enforces** edge-to-edge from API 35
(`targetSdk` 35+) whether an app asks or not. Opting in explicitly means the layout is the same on
older versions too, instead of shifting the first time a user's device updates.

The kit manages the *bars*, not your layout — a page whose content must not sit under them still
needs `SafeArea` (`Scaffold` already insets its `body`; a `Stack` or a custom scroll view does not).
This is the one thing to check on API 35+ hardware, because a widget test won't catch it.

Annotating one screen differently (a dark media player in a light app):

```dart
AnnotatedRegion<SystemUiOverlayStyle>(
  value: kitSystemUiOverlayStyle(Brightness.dark),
  child: player,
);
```

An app that drives `SystemChrome` itself: `KitApp(edgeToEdge: false, ...)`.

## Spacing

`AppSizes` — `s4…s64` values, `gap4…gap64` const `SizedBox`es, `radius*`/`borderRadius*`,
`pageAll`/`pageHorizontal`. Magic numbers in a widget are a review comment; so is a raw
`Color(0x...)` — read colors from `Theme.of(context).colorScheme`.

## Shared widgets

| Widget | Handles |
|---|---|
| `AppButton` | filled/outlined/text variants, built-in loading state, icon |
| `AppTextField` | consistent decoration, validator, formatters, obscure toggle plumbing |
| `AppCachedImage` | cached network image + placeholder + error, `.avatar()` variant |
| `AsyncValueWidget` / `AsyncValueSliverWidget` | loading/error/data for an `AsyncValue` |
| `PaginatedListView` | scroll-triggered load-more, pull-to-refresh, empty state |

Reach for these before writing a new widget, and keep business logic in providers — a widget that
decides *what* to fetch can't be reused by the next screen that needs the same view.

## Context extensions

`context.theme`, `textTheme`, `colorScheme`, `screenSize`, `showSnackBar(...)`,
`showConfirmDialog(...)`. `String` extensions: `capitalized`, `nullIfBlank`, `isValidEmail`,
`truncate(n)`.
