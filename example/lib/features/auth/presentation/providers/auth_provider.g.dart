// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages auth state reactively.
///
/// Andrea's tip #46: ref.watch vs ref.read vs ref.listen
/// — Widgets use ref.watch(authStateProvider) to rebuild on changes.
/// — One-shot actions use ref.read(authStateProvider.notifier).login(...)

@ProviderFor(AuthStateNotifier)
final authStateProvider = AuthStateNotifierProvider._();

/// Manages auth state reactively.
///
/// Andrea's tip #46: ref.watch vs ref.read vs ref.listen
/// — Widgets use ref.watch(authStateProvider) to rebuild on changes.
/// — One-shot actions use ref.read(authStateProvider.notifier).login(...)
final class AuthStateNotifierProvider
    extends $AsyncNotifierProvider<AuthStateNotifier, AuthState> {
  /// Manages auth state reactively.
  ///
  /// Andrea's tip #46: ref.watch vs ref.read vs ref.listen
  /// — Widgets use ref.watch(authStateProvider) to rebuild on changes.
  /// — One-shot actions use ref.read(authStateProvider.notifier).login(...)
  AuthStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateNotifierHash();

  @$internal
  @override
  AuthStateNotifier create() => AuthStateNotifier();
}

String _$authStateNotifierHash() => r'63f357f0ec36038f44131a2d4ebea589d1ff5fd4';

/// Manages auth state reactively.
///
/// Andrea's tip #46: ref.watch vs ref.read vs ref.listen
/// — Widgets use ref.watch(authStateProvider) to rebuild on changes.
/// — One-shot actions use ref.read(authStateProvider.notifier).login(...)

abstract class _$AuthStateNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
