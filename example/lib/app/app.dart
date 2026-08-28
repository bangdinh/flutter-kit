import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

/// **App rule**: brand palette. Only the tokens that differ from kit defaults.
const _brand = KitColors(
  primary: Color(0xFF2563EB),
  secondary: Color(0xFF7C3AED),
);

/// Root widget — hands the app's router and palette to the kit's shell.
class ExampleApp extends ConsumerWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KitApp(
      title: 'Flutter Kit Example',
      routerConfig: ref.watch(appRouterProvider),
      theme: KitTheme.light(_brand),
      darkTheme: KitTheme.dark(_brand),
    );
  }
}
