import 'package:flutter/material.dart';

/// Consistent spacing and sizing values.
///
/// Follows Andrea's tip #23: The Gap widget
/// — use consistent spacing tokens instead of magic numbers.
abstract final class AppSizes {
  // --- Spacing ---
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;
  static const double s64 = 64;

  // --- Gap widgets (for Row / Column) ---
  static const gap4 = SizedBox.square(dimension: s4);
  static const gap8 = SizedBox.square(dimension: s8);
  static const gap12 = SizedBox.square(dimension: s12);
  static const gap16 = SizedBox.square(dimension: s16);
  static const gap20 = SizedBox.square(dimension: s20);
  static const gap24 = SizedBox.square(dimension: s24);
  static const gap32 = SizedBox.square(dimension: s32);
  static const gap48 = SizedBox.square(dimension: s48);
  static const gap64 = SizedBox.square(dimension: s64);

  // --- Border Radius ---
  static const radius4 = Radius.circular(4);
  static const radius8 = Radius.circular(8);
  static const radius12 = Radius.circular(12);
  static const radius16 = Radius.circular(16);
  static const radius24 = Radius.circular(24);
  static const radiusFull = Radius.circular(999);

  static final borderRadius4 = BorderRadius.circular(4);
  static final borderRadius8 = BorderRadius.circular(8);
  static final borderRadius12 = BorderRadius.circular(12);
  static final borderRadius16 = BorderRadius.circular(16);
  static final borderRadius24 = BorderRadius.circular(24);

  // --- Page Padding ---
  static const pageHorizontal = EdgeInsets.symmetric(horizontal: s16);
  static const pageAll = EdgeInsets.all(s16);
}
