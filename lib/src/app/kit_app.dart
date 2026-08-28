import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_mode_provider.dart';
import '../theme/kit_theme.dart';

/// Root widget: a `MaterialApp.router` wired to the kit's persisted
/// [themeModeProvider], with edge-to-edge system bars handled correctly.
///
/// The kit does **not** know your routes — the app builds its own `GoRouter`
/// and passes it in as [routerConfig]. Themes default to [KitTheme] with kit
/// tokens; pass your own to rebrand.
class KitApp extends ConsumerStatefulWidget {
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
    this.edgeToEdge = true,
  });

  final String title;

  /// The app's router (`GoRouter`, or any `RouterConfig`).
  final RouterConfig<Object> routerConfig;

  final ThemeData? theme;
  final ThemeData? darkTheme;

  /// Wraps every page — banners, `MediaQuery` overrides, global overlays.
  /// Runs *inside* the edge-to-edge annotation, so it can override it.
  final TransitionBuilder? builder;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final Locale? locale;
  final bool debugShowCheckedModeBanner;

  /// Draw behind the system bars and keep their icons legible.
  ///
  /// Android enforces edge-to-edge from API 35 (`targetSdk` 35+) regardless of
  /// what the app asks for, so the kit opts in explicitly: the layout is then
  /// identical on older versions instead of shifting when a device updates.
  /// The kit only manages the *bars* — a page that must not sit under them
  /// still needs `SafeArea` (or `Scaffold`, which insets its `body` already).
  ///
  /// Set `false` only for an app that drives `SystemChrome` itself.
  final bool edgeToEdge;

  @override
  ConsumerState<KitApp> createState() => _KitAppState();
}

class _KitAppState extends ConsumerState<KitApp> {
  @override
  void initState() {
    super.initState();
    if (widget.edgeToEdge) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: widget.title,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      theme: widget.theme ?? KitTheme.light(),
      darkTheme: widget.darkTheme ?? KitTheme.dark(),
      themeMode: themeMode,
      routerConfig: widget.routerConfig,
      builder: _buildWithSystemBars,
      localizationsDelegates: widget.localizationsDelegates,
      supportedLocales: widget.supportedLocales,
      locale: widget.locale,
    );
  }

  /// Runs below `MaterialApp`'s `Theme`, so `Theme.of` here is the *resolved*
  /// theme — the bar icons follow a light/dark/system switch on their own.
  Widget _buildWithSystemBars(BuildContext context, Widget? child) {
    final content =
        widget.builder?.call(context, child) ??
        child ??
        const SizedBox.shrink();

    if (!widget.edgeToEdge) return content;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kitSystemUiOverlayStyle(Theme.of(context).brightness),
      child: content,
    );
  }
}

/// Transparent system bars with icons that contrast against a UI of the given
/// [brightness] — a light UI needs dark icons, so the values invert.
///
/// Exposed for apps that annotate a specific screen differently (a dark media
/// player inside a light app) and want the kit's values as the baseline.
SystemUiOverlayStyle kitSystemUiOverlayStyle(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final iconBrightness = isLight ? Brightness.dark : Brightness.light;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness, // Android
    statusBarBrightness: brightness, // iOS
    // Ignored from Android 15 (the bar is transparent by force) but still
    // correct on older versions, which the kit also supports.
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: iconBrightness,
  );
}
