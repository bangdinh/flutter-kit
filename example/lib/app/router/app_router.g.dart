// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [GoRouter] instance.
///
/// Follows Andrea's tip #36: GoRouter go vs push
/// — use go() for top-level navigation, push() for sub-pages.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides the [GoRouter] instance.
///
/// Follows Andrea's tip #36: GoRouter go vs push
/// — use go() for top-level navigation, push() for sub-pages.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the [GoRouter] instance.
  ///
  /// Follows Andrea's tip #36: GoRouter go vs push
  /// — use go() for top-level navigation, push() for sub-pages.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'54c4d0eae493860dc7e2156ef24a8bd625fdd809';
