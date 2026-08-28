// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'1607802c576da2a4ff4dc37b8a4f20543fad9869';

/// App rule: how to refresh an expired token. `null` = no refresh, a `401`
/// surfaces immediately.

@ProviderFor(tokenRefresher)
final tokenRefresherProvider = TokenRefresherProvider._();

/// App rule: how to refresh an expired token. `null` = no refresh, a `401`
/// surfaces immediately.

final class TokenRefresherProvider
    extends
        $FunctionalProvider<TokenRefresher?, TokenRefresher?, TokenRefresher?>
    with $Provider<TokenRefresher?> {
  /// App rule: how to refresh an expired token. `null` = no refresh, a `401`
  /// surfaces immediately.
  TokenRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenRefresherHash();

  @$internal
  @override
  $ProviderElement<TokenRefresher?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenRefresher? create(Ref ref) {
    return tokenRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenRefresher? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenRefresher?>(value),
    );
  }
}

String _$tokenRefresherHash() => r'073e1d02798350f14db3c18c47108e4b4940ca8a';

/// App rule: what to do when auth is definitively lost (clear session,
/// navigate to login, show a dialog…). Runs after refresh failed or was absent.

@ProviderFor(unauthorizedHandler)
final unauthorizedHandlerProvider = UnauthorizedHandlerProvider._();

/// App rule: what to do when auth is definitively lost (clear session,
/// navigate to login, show a dialog…). Runs after refresh failed or was absent.

final class UnauthorizedHandlerProvider
    extends
        $FunctionalProvider<
          void Function()?,
          void Function()?,
          void Function()?
        >
    with $Provider<void Function()?> {
  /// App rule: what to do when auth is definitively lost (clear session,
  /// navigate to login, show a dialog…). Runs after refresh failed or was absent.
  UnauthorizedHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unauthorizedHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unauthorizedHandlerHash();

  @$internal
  @override
  $ProviderElement<void Function()?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void Function()? create(Ref ref) {
    return unauthorizedHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void Function()? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void Function()?>(value),
    );
  }
}

String _$unauthorizedHandlerHash() =>
    r'300231a871a2506a48c0ad9a1c4656f2568f9041';
