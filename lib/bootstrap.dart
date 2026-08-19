import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/env/app_env.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/local_storage.dart';

/// Initializes the app and runs it inside a [ProviderScope].
///
/// Andrea's tip #56: Async init with provider overrides
/// — pre-initialize async dependencies, then override providers
/// so they're available synchronously throughout the app.
Future<void> bootstrap({AppEnv env = AppEnv.dev}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure environment
  EnvConfig.init(env);
  AppLogger.i('Starting app in ${env.label} mode');

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Pre-initialize async dependencies
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run app with provider overrides
  runApp(
    ProviderScope(
      overrides: [
        // Override the localStorage provider with the real instance
        localStorageProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
