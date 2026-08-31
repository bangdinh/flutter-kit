import 'dart:async';

import '../../models/paginated_state.dart';
import '../models/api_envelope.dart';

/// Cursor pagination for a Riverpod notifier, matching gokit's `page` envelope.
///
/// Implement [fetchPage] and the mixin handles first load, load-more, refresh,
/// the in-flight guard and error capture:
///
/// ```dart
/// @riverpod
/// class ArticleList extends _$ArticleList with PaginatedNotifier<Article> {
///   @override
///   Future<ApiPage<Article>> fetchPage(String? cursor) =>
///       ref.read(articleRepositoryProvider).getArticles(
///             cursor: cursor,
///             limit: pageSize,
///           );
///
///   @override
///   PaginatedState<Article> build() {
///     loadFirstPage();
///     return const PaginatedState();
///   }
/// }
/// ```
///
/// Pass `cursor` straight through to the API as an opaque value — never parse,
/// increment or persist it.
mixin PaginatedNotifier<T> {
  /// Provided by the generated `_$ClassName` base class.
  PaginatedState<T> get state;
  set state(PaginatedState<T> value);

  /// Requested page size. The server may clamp it; trust `page.limit` in the
  /// response over this value.
  int get pageSize => 20;

  /// Fetches one page. `cursor` is `null` for the first page.
  Future<ApiPage<T>> fetchPage(String? cursor);

  /// Kicks off the first load. Call from `build()`.
  void loadFirstPage() {
    // Deferred: `build()` must not mutate state while it is running.
    Future.microtask(() => _load(null, isRefresh: true));
  }

  /// Loads the next page. Safe to call from a scroll listener — it no-ops while
  /// a load is in flight, at the end of the list, or with no cursor to advance.
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final cursor = state.nextCursor;
    if (cursor == null) return;
    await _load(cursor);
  }

  /// Discards everything and reloads from the first page.
  Future<void> refresh() async {
    state = state.reset();
    await _load(null, isRefresh: true);
  }

  Future<void> _load(String? cursor, {bool isRefresh = false}) async {
    state = state.copyWith(isLoadingMore: !isRefresh, clearError: true);

    try {
      final page = await fetchPage(cursor);
      if (isRefresh) {
        state = PaginatedState<T>(
          items: page.items,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          total: page.page.total,
        );
      } else {
        state = state.appendPage(
          page.items,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          total: page.page.total,
        );
      }
    } on Object catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }
}
