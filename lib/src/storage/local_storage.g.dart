// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [SharedPreferences] for non-sensitive key-value storage.
///
/// Andrea's tip #56: Async init with provider overrides
/// — initialized in bootstrap, overridden in ProviderScope.

@ProviderFor(localStorage)
final localStorageProvider = LocalStorageProvider._();

/// Provides [SharedPreferences] for non-sensitive key-value storage.
///
/// Andrea's tip #56: Async init with provider overrides
/// — initialized in bootstrap, overridden in ProviderScope.

final class LocalStorageProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Provides [SharedPreferences] for non-sensitive key-value storage.
  ///
  /// Andrea's tip #56: Async init with provider overrides
  /// — initialized in bootstrap, overridden in ProviderScope.
  LocalStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localStorageHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return localStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$localStorageHash() => r'6ea07ebf10aa6c3c248aebe752ad92595b030562';
