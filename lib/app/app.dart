import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/theme_mode_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget of the application.
///
/// Uses [ConsumerWidget] instead of StatelessWidget to access Riverpod.
/// Andrea's tip #40: Anatomy of a Riverpod Provider
/// — the entire app tree can read providers via ref.watch().
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Flutter Kit',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Router
      routerConfig: router,
    );
  }
}
