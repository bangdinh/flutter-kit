import 'package:flutter/material.dart';

import '../models/paginated_state.dart';

/// Reusable paginated ListView with built-in load-more and pull-to-refresh.
///
/// Pairs with [PaginatedNotifier] from core/network/helpers.
///
/// Usage:
///   ```dart
///   PaginatedListView<Article>(
///     state: ref.watch(articleListProvider),
///     onLoadMore: () => ref.read(articleListProvider.notifier).loadNextPage(),
///     onRefresh: () => ref.read(articleListProvider.notifier).refresh(),
///     itemBuilder: (context, article, index) => ArticleCard(article: article),
///   )
///   ```
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    this.emptyWidget,
    this.separatorBuilder,
    this.padding,
    this.loadMoreThreshold = 200.0,
    this.physics,
    this.header,
  });

  final PaginatedState<T> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final Widget? emptyWidget;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;
  final ScrollPhysics? physics;
  final Widget? header;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.state.items;

    if (items.isEmpty && !widget.state.isLoadingMore) {
      return widget.emptyWidget ?? const _DefaultEmptyWidget();
    }

    final itemCount = items.length + (widget.state.hasMore ? 1 : 0);
    final hasHeader = widget.header != null;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding ?? const EdgeInsets.all(16),
        itemCount: itemCount + (hasHeader ? 1 : 0),
        separatorBuilder:
            widget.separatorBuilder ?? (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Header
          if (hasHeader && index == 0) return widget.header!;

          final itemIndex = hasHeader ? index - 1 : index;

          // Load more indicator
          if (itemIndex >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return widget.itemBuilder(context, items[itemIndex], itemIndex);
        },
      ),
    );
  }
}

class _DefaultEmptyWidget extends StatelessWidget {
  const _DefaultEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
