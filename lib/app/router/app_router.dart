import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

/// Provides the [GoRouter] instance.
///
/// Follows Andrea's tip #36: GoRouter go vs push
/// — use go() for top-level navigation, push() for sub-pages.
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateNotifierProvider);

  return GoRouter(
    initialLocation: RoutePaths.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final isLoginRoute = state.matchedLocation == RoutePaths.login;

      // Not logged in → redirect to login
      if (!isLoggedIn && !isLoginRoute) {
        return RoutePaths.login;
      }

      // Logged in but on login page → redirect to home
      if (isLoggedIn && isLoginRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('🏠 Home — replace with your page')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
