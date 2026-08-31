import 'package:flutter/foundation.dart';

/// State of a cursor-paginated list.
///
/// gokit paginates by **opaque cursor**, not page number: there is no "page 3"
/// to jump to, and the only way to advance is to echo [nextCursor] back. Hence
/// no `page`/`totalPages` here — [hasMore] is the server's word on whether more
/// exists, and it is authoritative even when a page came back short.
@immutable
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.total,
    this.error,
  });

  final List<T> items;

  /// Cursor to send for the next page; `null` when the server sent none.
  final String? nextCursor;

  final bool isLoadingMore;

  /// Starts `true` so the first load is allowed; the server decides afterwards.
  final bool hasMore;

  /// Only when the service could compute it cheaply — often `null`.
  final int? total;

  final Object? error;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    bool? hasMore,
    int? total,
    Object? error,
    bool clearError = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Appends a freshly fetched page.
  PaginatedState<T> appendPage(
    List<T> newItems, {
    required bool hasMore,
    String? nextCursor,
    int? total,
  }) {
    return PaginatedState<T>(
      items: [...items, ...newItems],
      nextCursor: nextCursor,
      isLoadingMore: false,
      hasMore: hasMore,
      total: total ?? this.total,
    );
  }

  /// Back to the initial state, for a pull-to-refresh.
  PaginatedState<T> reset() => PaginatedState<T>();
}
