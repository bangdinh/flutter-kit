/// flutter_kit — base framework for FPT B2B Flutter apps.
///
/// The kit owns the skeleton: app bootstrap, Dio stack, storage, error
/// contract, `Result`, pagination, theme system, shared widgets. An app owns
/// its rules: environment resolution, routes, features, auth policy, palette.
///
/// Single entry point — `import 'package:flutter_kit/flutter_kit.dart';`.
/// Anything not exported here is internal to the kit (`lib/src/`) and may
/// change without a major bump.
library;

// --- App shell -------------------------------------------------------------
export 'src/app/kit_app.dart';
export 'src/app/kit_bootstrap.dart';
export 'src/app/kit_config.dart';

// --- Extensions ------------------------------------------------------------
export 'src/extensions/context_ext.dart';
export 'src/extensions/string_ext.dart';

// --- Logging ---------------------------------------------------------------
export 'src/logging/app_logger.dart';

// --- Models ----------------------------------------------------------------
export 'src/models/paginated_state.dart';
export 'src/models/result.dart';

// --- Network ---------------------------------------------------------------
export 'src/network/api_client.dart';
export 'src/network/errors/api_exception.dart';
export 'src/network/errors/problem_detail.dart';
export 'src/network/helpers/api_error_handler.dart';
export 'src/network/helpers/paginated_notifier.dart';
export 'src/network/interceptors/auth_interceptor.dart';
export 'src/network/interceptors/error_interceptor.dart';
export 'src/network/interceptors/retry_interceptor.dart';
export 'src/network/models/api_envelope.dart';
export 'src/network/token_store.dart';

// --- Providers -------------------------------------------------------------
export 'src/providers/app_lifecycle_provider.dart';
export 'src/providers/theme_mode_provider.dart';

// --- Storage ---------------------------------------------------------------
export 'src/storage/local_storage.dart';
export 'src/storage/secure_storage.dart';

// --- Theme -----------------------------------------------------------------
export 'src/theme/app_sizes.dart';
export 'src/theme/kit_colors.dart';
export 'src/theme/kit_theme.dart';

// --- UI --------------------------------------------------------------------
export 'src/ui/app_button.dart';
export 'src/ui/app_cached_image.dart';
export 'src/ui/app_text_field.dart';
export 'src/ui/async_value_widget.dart';
export 'src/ui/paginated_list_view.dart';
