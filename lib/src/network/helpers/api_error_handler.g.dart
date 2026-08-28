// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active [ApiErrorMessages]. Override in the app for localized copy.

@ProviderFor(apiErrorMessages)
final apiErrorMessagesProvider = ApiErrorMessagesProvider._();

/// The active [ApiErrorMessages]. Override in the app for localized copy.

final class ApiErrorMessagesProvider
    extends
        $FunctionalProvider<
          ApiErrorMessages,
          ApiErrorMessages,
          ApiErrorMessages
        >
    with $Provider<ApiErrorMessages> {
  /// The active [ApiErrorMessages]. Override in the app for localized copy.
  ApiErrorMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiErrorMessagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiErrorMessagesHash();

  @$internal
  @override
  $ProviderElement<ApiErrorMessages> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiErrorMessages create(Ref ref) {
    return apiErrorMessages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiErrorMessages value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiErrorMessages>(value),
    );
  }
}

String _$apiErrorMessagesHash() => r'ea7f2b8559c60607c1d095faad8bc8e229c3f27d';
