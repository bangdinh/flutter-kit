import 'package:flutter_kit/flutter_kit.dart';

import 'app/app.dart';
import 'app/env/app_env.dart';

/// Wires **this app's rules** into the kit and starts it.
///
/// The kit owns the boot sequence ([bootstrapKit]); the app owns what goes
/// into it: which environment, which auth policy, which overrides.
Future<void> bootstrap({AppEnv env = AppEnv.dev}) {
  return bootstrapKit(
    config: env.toKitConfig(),
    appBuilder: () => const ExampleApp(),
    overrides: [
      // App rule: no refresh-token endpoint in this demo, so a 401 logs out.
      unauthorizedHandlerProvider.overrideWithValue(() {
        AppLogger.w('Session lost — app should route to /login');
      }),
    ],
  );
}
