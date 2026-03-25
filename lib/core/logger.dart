import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void setMinLevel(LogLevel level) => _minLevel = level;

  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final prefix = switch (level) {
      LogLevel.debug => '[D]',
      LogLevel.info => '[I]',
      LogLevel.warning => '[W]',
      LogLevel.error => '[E]',
    };

    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? ' | $error' : '';
    final logMessage = '$prefix $tagStr$message$errorStr';

    if (kDebugMode) {
      developer.log(
        logMessage,
        name: tag ?? 'WooriSan',
        error: error,
        stackTrace: stackTrace,
        level: level == LogLevel.error ? 1000 : 0,
      );
    }
  }
}
