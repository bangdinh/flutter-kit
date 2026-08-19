/// Utility extensions on [String].
extension StringExt on String {
  /// Capitalizes the first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns null if blank (empty or whitespace only).
  String? get nullIfBlank => trim().isEmpty ? null : this;

  /// Basic email validation.
  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Truncates to [maxLength] and appends '…' if needed.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';
}

/// Extension on nullable strings for safe operations.
extension NullableStringExt on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  bool get isNotNullOrBlank => !isNullOrBlank;
}
