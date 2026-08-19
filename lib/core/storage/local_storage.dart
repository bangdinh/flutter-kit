import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_storage.g.dart';

/// Provides [SharedPreferences] for non-sensitive key-value storage.
///
/// Andrea's tip #56: Async init with provider overrides
/// — initialized in bootstrap, overridden in ProviderScope.
@Riverpod(keepAlive: true)
SharedPreferences localStorage(LocalStorageRef ref) {
  // This will be overridden in bootstrap.dart with the real instance.
  throw UnimplementedError(
    'localStorage must be overridden with a pre-initialized SharedPreferences. '
    'See bootstrap.dart for setup.',
  );
}
