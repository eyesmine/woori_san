import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/logger.dart';

void main() {
  group('AppLogger', () {
    test('setMinLevel works', () {
      // Should not throw
      AppLogger.setMinLevel(LogLevel.error);
      AppLogger.debug('this should be filtered');
      AppLogger.info('this should be filtered');
      AppLogger.warning('this should be filtered');
      AppLogger.error('this should show');

      // Reset
      AppLogger.setMinLevel(LogLevel.debug);
    });

    test('all log levels execute without error', () {
      AppLogger.debug('debug message', tag: 'Test');
      AppLogger.info('info message', tag: 'Test');
      AppLogger.warning('warning message', tag: 'Test', error: 'test error');
      AppLogger.error('error message', tag: 'Test', error: Exception('test'), stackTrace: StackTrace.current);
    });
  });
}
