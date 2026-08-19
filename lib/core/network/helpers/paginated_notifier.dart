import 'dart:async';

import '../../../shared/models/paginated_state.dart';
import '../models/api_response.dart';

/// Base mixin for paginated list providers.
///
/// Subclass this in your feature's provider to get pagination for free.
///
/// Usage:
///   ```dart
///   @riverpod
///   class ArticleList extends _$ArticleList
///       with PaginatedNotifier<Article> {
///
///     @override
///     int get pageSize => 20;
///
///     @override
///     Future<PaginatedResponse<Article>> fetchPage(int page) async {
///       final repo = ref.read(articleRepositoryProvider);
///       return repo.getArticles(page: page, limit: pageSize);
///     }
///
///     @override
///     PaginatedState<Article> build() {
///       loadFirstPage();
///       return const PaginatedState();
///     }
///   }
///   ```
mixin PaginatedNotifier<T> {
  /// Riverpod 3.x: state is provided by the generated `_$ClassName`
  /// base class. The mixin accesses it through these abstract members.
  PaginatedState<T> get state;
  set state(PaginatedState<T> value);

  int get pageSize => 20;

  /// Implement this to fetch a page from your data source.
  Future<PaginatedResponse<T>> fetchPage(int page);

  /// Loads the first page. Call from [build].
  void loadFirstPage() {
    // Use Future.microtask to avoid modifying state during build
    Future.microtask(() => _loadPage(1, isRefresh: true));
  }

  /// Loads the next page. Call from scroll listener.
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await _loadPage(state.page + 1);
  }

  /// Refreshes from page 1.
  Future<void> refresh() async {
    state = state.reset();
    await _loadPage(1, isRefresh: true);
  }

  Future<void> _loadPage(int page, {bool isRefresh = false}) async {
    state = state.copyWith(isLoadingMore: !isRefresh, clearError: true);

    try {
      final response = await fetchPage(page);
      if (isRefresh) {
        state = PaginatedState<T>(
          items: response.items,
          page: page,
          hasMore: response.hasMore,
        );
      } else {
        state = state.appendPage(response.items, hasMore: response.hasMore);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e,
      );
    }
  }
}
