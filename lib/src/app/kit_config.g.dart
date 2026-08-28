// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kit_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active [KitConfig].
///
/// Overridden by `bootstrapKit`; in tests override it directly:
/// `kitConfigProvider.overrideWithValue(const KitConfig(apiBaseUrl: '...'))`.

@ProviderFor(kitConfig)
final kitConfigProvider = KitConfigProvider._();

/// The active [KitConfig].
///
/// Overridden by `bootstrapKit`; in tests override it directly:
/// `kitConfigProvider.overrideWithValue(const KitConfig(apiBaseUrl: '...'))`.

final class KitConfigProvider
    extends $FunctionalProvider<KitConfig, KitConfig, KitConfig>
    with $Provider<KitConfig> {
  /// The active [KitConfig].
  ///
  /// Overridden by `bootstrapKit`; in tests override it directly:
  /// `kitConfigProvider.overrideWithValue(const KitConfig(apiBaseUrl: '...'))`.
  KitConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitConfigHash();

  @$internal
  @override
  $ProviderElement<KitConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KitConfig create(Ref ref) {
    return kitConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KitConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KitConfig>(value),
    );
  }
}

String _$kitConfigHash() => r'3ab8250d1f3aa602983192c680eb2f1fe218e7ad';
