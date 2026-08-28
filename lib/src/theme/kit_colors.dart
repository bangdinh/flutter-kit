import 'package:flutter/material.dart';

/// Color tokens the kit's theme is built from.
///
/// The kit owns the *shape* of the palette; an app owns the *values*. Rebrand
/// by passing a [KitColors] to `KitTheme.light` / `KitTheme.dark`:
///   ```dart
///   const brand = KitColors(primary: Color(0xFF0F62FE), ...);
///   KitTheme.light(brand)
///   ```
/// Only override the tokens you care about — the rest keep kit defaults.
@immutable
class KitColors {
  const KitColors({
    this.primary = const Color(0xFF2563EB),
    this.primaryLight = const Color(0xFF60A5FA),
    this.primaryDark = const Color(0xFF1D4ED8),
    this.secondary = const Color(0xFF7C3AED),
    this.secondaryLight = const Color(0xFFA78BFA),
    this.background = const Color(0xFFF8FAFC),
    this.surface = const Color(0xFFFFFFFF),
    this.surfaceVariant = const Color(0xFFF1F5F9),
    this.textPrimary = const Color(0xFF0F172A),
    this.textSecondary = const Color(0xFF64748B),
    this.textTertiary = const Color(0xFF94A3B8),
    this.border = const Color(0xFFE2E8F0),
    this.divider = const Color(0xFFF1F5F9),
    this.success = const Color(0xFF10B981),
    this.warning = const Color(0xFFF59E0B),
    this.error = const Color(0xFFEF4444),
    this.info = const Color(0xFF3B82F6),
    this.backgroundDark = const Color(0xFF0F172A),
    this.surfaceDark = const Color(0xFF1E293B),
    this.surfaceVariantDark = const Color(0xFF334155),
    this.textPrimaryDark = const Color(0xFFF8FAFC),
    this.textSecondaryDark = const Color(0xFF94A3B8),
    this.borderDark = const Color(0xFF334155),
  });

  /// Kit defaults — used when an app passes no palette.
  static const KitColors defaults = KitColors();

  // --- Brand ---
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;

  // --- Neutral (light) ---
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color divider;

  // --- Semantic ---
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // --- Neutral (dark) ---
  final Color backgroundDark;
  final Color surfaceDark;
  final Color surfaceVariantDark;
  final Color textPrimaryDark;
  final Color textSecondaryDark;
  final Color borderDark;
}
