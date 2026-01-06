// lib/core/utils/log_helper.dart
import 'package:flutter/foundation.dart';

class Logger {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';

  /// Logs an info message in green
  static void info(String message, {String tag = 'INFO'}) {
    _log('$_green[$tag] $message$_reset');
  }

  /// Logs a warning message in yellow
  static void warning(String message, {String tag = 'WARNING'}) {
    _log('$_yellow[$tag] $message$_reset');
  }

  /// Logs an error message in red
  static void error(String message, {String tag = 'ERROR'}) {
    _log('$_red[$tag] $message$_reset');
  }

  /// Logs a debug message in blue (only in debug mode)
  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      _log('$_blue[$tag] $message$_reset');
    }
  }

  /// Prints to console (safe wrapper)
  static void _log(String formattedMessage) {
    // ignore: avoid_print
    print(formattedMessage);
  }
}
