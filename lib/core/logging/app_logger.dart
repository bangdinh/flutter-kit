import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Lightweight logger — wraps [dev.log] in debug, no-op in release.
///
/// Usage:
///   AppLogger.d('some debug message');
///   AppLogger.e('error happened', error: e, stackTrace: st);
class AppLogger {
  AppLogger._();

  static void d(String message, {String tag = 'FlutterKit'}) {
    if (kDebugMode) {
      dev.log(message, name: tag);
    }
  }

  static void i(String message, {String tag = 'FlutterKit'}) {
    if (kDebugMode) {
      dev.log('ℹ️ $message', name: tag);
    }
  }

  static void w(String message, {String tag = 'FlutterKit'}) {
    if (kDebugMode) {
      dev.log('⚠️ $message', name: tag);
    }
  }

  static void e(
    String message, {
    String tag = 'FlutterKit',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      dev.log(
        '❌ $message',
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
