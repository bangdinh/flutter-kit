/// Barrel file for core layer.
///
/// Import one file to access all core utilities:
///   `import 'package:flutter_kit/core/core.dart';`
library;

// Extensions
export 'extensions/context_ext.dart';
export 'extensions/string_ext.dart';

// Logging
export 'logging/app_logger.dart';

// Network
export 'network/api_client.dart';
export 'network/errors/api_exception.dart';
export 'network/helpers/api_error_handler.dart';
export 'network/helpers/paginated_notifier.dart';
export 'network/models/api_response.dart';

// Providers
export 'providers/app_lifecycle_provider.dart';
export 'providers/theme_mode_provider.dart';

// Storage
export 'storage/local_storage.dart';
export 'storage/secure_storage.dart';
