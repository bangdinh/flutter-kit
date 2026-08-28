/// State for paginated list views.
///
/// Generic enough to work with any feature's list.
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.page = 1,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<T> items;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Returns a new state with the next page's items appended.
  PaginatedState<T> appendPage(List<T> newItems, {required bool hasMore}) {
    return copyWith(
      items: [...items, ...newItems],
      page: page + 1,
      isLoadingMore: false,
      hasMore: hasMore,
      clearError: true,
    );
  }

  /// Returns state reset to initial.
  PaginatedState<T> reset() => const PaginatedState();
}
