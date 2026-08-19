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
class AppLifecycle extends _$AppLifecycle with WidgetsBindingObserver {
  @override
  AppLifecycleState build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return AppLifecycleState.resumed;
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
  }
}
