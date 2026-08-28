// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lifecycle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AppLifecycle)
final appLifecycleProvider = AppLifecycleProvider._();

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
final class AppLifecycleProvider
    extends $NotifierProvider<AppLifecycle, AppLifecycleState> {
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
  AppLifecycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLifecycleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLifecycleHash();

  @$internal
  @override
  AppLifecycle create() => AppLifecycle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleState>(value),
    );
  }
}

String _$appLifecycleHash() => r'41f8fe9d87da2dbdfe808cf51e684d114ca98530';

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

abstract class _$AppLifecycle extends $Notifier<AppLifecycleState> {
  AppLifecycleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLifecycleState, AppLifecycleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLifecycleState, AppLifecycleState>,
              AppLifecycleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
