import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal `RouterConfig` — the kit has no router of its own, and this test is
/// about the system-bar handling, not navigation.
class _StubRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const [MaterialPage<void>(child: Scaffold(body: Text('home')))],
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

Future<SharedPreferences> _prefs(Map<String, Object> initial) {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required SharedPreferences prefs,
  bool edgeToEdge = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(prefs)],
      child: KitApp(
        title: 'test',
        routerConfig: RouterConfig<Object>(
          routerDelegate: _StubRouterDelegate(),
        ),
        edgeToEdge: edgeToEdge,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SystemUiOverlayStyle _appliedStyle(WidgetTester tester) {
  return tester
      .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      )
      .value;
}

void main() {
  group('kitSystemUiOverlayStyle', () {
    test('inverts icon brightness against the UI it sits on', () {
      final light = kitSystemUiOverlayStyle(Brightness.light);
      expect(light.statusBarIconBrightness, Brightness.dark);
      expect(light.systemNavigationBarIconBrightness, Brightness.dark);
      expect(light.statusBarBrightness, Brightness.light); // iOS reads this one

      final dark = kitSystemUiOverlayStyle(Brightness.dark);
      expect(dark.statusBarIconBrightness, Brightness.light);
      expect(dark.systemNavigationBarIconBrightness, Brightness.light);
    });

    test('makes both bars transparent so the app draws behind them', () {
      final style = kitSystemUiOverlayStyle(Brightness.light);
      expect(style.statusBarColor, Colors.transparent);
      expect(style.systemNavigationBarColor, Colors.transparent);
    });
  });

  group('KitApp', () {
    testWidgets('opts into edge-to-edge on start', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await _pumpApp(tester, prefs: await _prefs({}));

      expect(
        calls.where((c) => c.method == 'SystemChrome.setEnabledSystemUIMode'),
        isNotEmpty,
      );
    });

    testWidgets('annotates dark bar icons for a light theme', (tester) async {
      await _pumpApp(tester, prefs: await _prefs({'theme_mode': 'light'}));

      expect(_appliedStyle(tester).statusBarIconBrightness, Brightness.dark);
    });

    testWidgets('follows the persisted theme mode into dark', (tester) async {
      await _pumpApp(tester, prefs: await _prefs({'theme_mode': 'dark'}));

      expect(_appliedStyle(tester).statusBarIconBrightness, Brightness.light);
    });

    testWidgets('edgeToEdge: false leaves the bars to the app', (tester) async {
      await _pumpApp(
        tester,
        prefs: await _prefs({'theme_mode': 'light'}),
        edgeToEdge: false,
      );

      expect(find.byType(AnnotatedRegion<SystemUiOverlayStyle>), findsNothing);
    });
  });
}
