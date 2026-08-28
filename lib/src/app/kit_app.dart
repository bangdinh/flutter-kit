import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_mode_provider.dart';
import '../theme/kit_theme.dart';

/// Root widget: a `MaterialApp.router` wired to the kit's persisted
/// [themeModeProvider].
///
/// The kit does **not** know your routes — the app builds its own `GoRouter`
/// and passes it in as [routerConfig]. Themes default to [KitTheme] with kit
/// tokens; pass your own to rebrand.
class KitApp extends ConsumerWidget {
  const KitApp({
    super.key,
    required this.title,
    required this.routerConfig,
    this.theme,
    this.darkTheme,
    this.builder,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
    this.locale,
    this.debugShowCheckedModeBanner = false,
  });

  final String title;

  /// The app's router (`GoRouter`, or any `RouterConfig`).
  final RouterConfig<Object> routerConfig;

  final ThemeData? theme;
  final ThemeData? darkTheme;

  /// Wraps every page — banners, `MediaQuery` overrides, global overlays.
  final TransitionBuilder? builder;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final Locale? locale;
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: theme ?? KitTheme.light(),
      darkTheme: darkTheme ?? KitTheme.dark(),
      themeMode: themeMode,
      routerConfig: routerConfig,
      builder: builder,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: locale,
    );
  }
}
