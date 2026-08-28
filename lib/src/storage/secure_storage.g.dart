// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Abstraction over [FlutterSecureStorage] for auth tokens.
///
/// Riverpod replaces get_it here — this provider is the DI container.

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// Abstraction over [FlutterSecureStorage] for auth tokens.
///
/// Riverpod replaces get_it here — this provider is the DI container.

final class SecureStorageProvider
    extends $FunctionalProvider<SecureStorage, SecureStorage, SecureStorage>
    with $Provider<SecureStorage> {
  /// Abstraction over [FlutterSecureStorage] for auth tokens.
  ///
  /// Riverpod replaces get_it here — this provider is the DI container.
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<SecureStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'5c9908c0046ad0e39469ee7acbb5540397b36693';
