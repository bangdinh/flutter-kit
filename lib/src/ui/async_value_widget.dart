import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reusable widget to handle [AsyncValue] states.
///
/// Andrea's tip #15: AsyncValueWidget
/// — eliminates repetitive loading/error/data boilerplate.
///
/// Usage:
///   ```dart
///   final userAsync = ref.watch(userProvider);
///   AsyncValueWidget(
///     value: userAsync,
///     data: (user) => Text(user.name),
///   )
///   ```
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      data: data,
      loading:
          () =>
              loading?.call() ??
              const Center(child: CircularProgressIndicator()),
      error:
          (e, st) =>
              error?.call(e, st) ??
              _DefaultErrorWidget(error: e, stackTrace: st),
    );
  }
}

/// Sliver variant for use inside [CustomScrollView].
class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading:
          () =>
              loading?.call() ??
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
      error:
          (e, st) =>
              error?.call(e, st) ??
              SliverToBoxAdapter(
                child: _DefaultErrorWidget(error: e, stackTrace: st),
              ),
    );
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({required this.error, required this.stackTrace});

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
