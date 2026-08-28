import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_provider.g.dart';

/// Exposes [AppLifecycleState] as a Riverpod provider.
///
/// Andrea's tip #34: How to use WidgetsBindingObserver
/// — wrapped as a provider so any widget/provider can react to lifecycle.
///
/// Usage:
///   ```dart
///   ref.listen(appLifecycleProvider, (prev, next) {
///     if (next == AppLifecycleState.resumed) {
///       // Refresh data when app comes to foreground
///     }
///   });
///   ```
@Riverpod(keepAlive: true)
class AppLifecycle extends _$AppLifecycle {
  @override
  AppLifecycleState build() {
    final observer = _AppLifecycleObserver(
      onChanged: (appState) => state = appState,
    );
    final binding = WidgetsBinding.instance;
    binding.addObserver(observer);
    ref.onDispose(() => binding.removeObserver(observer));
    return AppLifecycleState.resumed;
  }
}

/// Separate observer class since Riverpod 3.x notifiers
/// cannot use `with WidgetsBindingObserver`.
class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver({required this.onChanged});

  final ValueChanged<AppLifecycleState> onChanged;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChanged(state);
  }
}
