import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// 외부 에러 리포터 콜백 (Crashlytics 등 연동 시 설정)
typedef ErrorReporter = void Function(String message, Object? error, StackTrace? stackTrace);

class AppLogger {
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static ErrorReporter? _errorReporter;

  static void setMinLevel(LogLevel level) => _minLevel = level;

  /// 프로덕션 에러 리포터 설정 (예: Firebase Crashlytics)
  static void setErrorReporter(ErrorReporter reporter) => _errorReporter = reporter;

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

    // 프로덕션 에러 리포팅 (error/warning)
    if (!kDebugMode && level.index >= LogLevel.warning.index && _errorReporter != null) {
      _errorReporter!(logMessage, error, stackTrace);
    }
  }
}
