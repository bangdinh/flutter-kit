import 'package:flutter/material.dart';

import 'kit_colors.dart';

/// Builds Material 3 [ThemeData] from [KitColors] tokens.
///
/// The kit fixes the component shapes an app shouldn't have to re-decide
/// (48pt buttons, 12pt radii, flat app bar, filled inputs). Swap the palette
/// with [colors]; for anything beyond that, `.copyWith(...)` the result —
/// don't fork this file into your app.
abstract final class KitTheme {
  static ThemeData light([KitColors colors = KitColors.defaults]) {
    final scheme = ColorScheme.light(
      primary: colors.primary,
      onPrimary: Colors.white,
      primaryContainer: colors.primaryLight,
      secondary: colors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: colors.secondaryLight,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceVariant,
      error: colors.error,
      onError: Colors.white,
      outline: colors.border,
    );

    return _base(
      scheme: scheme,
      brightness: Brightness.light,
      scaffoldBackground: colors.background,
      dividerColor: colors.divider,
      appBarBackground: colors.surface,
      appBarForeground: colors.textPrimary,
      inputFill: colors.surfaceVariant,
      inputBorder: colors.border,
      accent: colors.primary,
      onAccent: Colors.white,
      cardColor: colors.surface,
      cardBorder: colors.border,
      errorColor: colors.error,
    );
  }

  static ThemeData dark([KitColors colors = KitColors.defaults]) {
    final scheme = ColorScheme.dark(
      primary: colors.primaryLight,
      onPrimary: Colors.black,
      primaryContainer: colors.primaryDark,
      secondary: colors.secondaryLight,
      onSecondary: Colors.black,
      surface: colors.surfaceDark,
      onSurface: colors.textPrimaryDark,
      surfaceContainerHighest: colors.surfaceVariantDark,
      error: colors.error,
      onError: Colors.white,
      outline: colors.borderDark,
    );

    return _base(
      scheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackground: colors.backgroundDark,
      dividerColor: colors.borderDark,
      appBarBackground: colors.surfaceDark,
      appBarForeground: colors.textPrimaryDark,
      inputFill: colors.surfaceVariantDark,
      inputBorder: colors.borderDark,
      accent: colors.primaryLight,
      onAccent: Colors.black,
      cardColor: colors.surfaceDark,
      cardBorder: colors.borderDark,
      errorColor: colors.error,
    );
  }

  static ThemeData _base({
    required ColorScheme scheme,
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color dividerColor,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color inputFill,
    required Color inputBorder,
    required Color accent,
    required Color onAccent,
    required Color cardColor,
    required Color cardBorder,
    required Color errorColor,
  }) {
    OutlineInputBorder outline(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: outline(inputBorder),
        focusedBorder: outline(accent, width: 1.5),
        errorBorder: outline(errorColor),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cardBorder),
        ),
      ),
    );
  }
}
