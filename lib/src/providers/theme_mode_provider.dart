import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/local_storage.dart';

part 'theme_mode_provider.g.dart';

/// Persisted theme mode (system/light/dark).
///
/// Changes are saved to SharedPreferences and survive app restart.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _key = 'theme_mode';

  SharedPreferences get _prefs => ref.read(localStorageProvider);

  @override
  ThemeMode build() {
    final stored = _prefs.getString(_key);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }

  Future<void> toggleTheme() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }
}
