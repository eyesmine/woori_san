import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/exceptions.dart';

void main() {
  group('Exception hierarchy', () {
    test('ValidationException firstFieldError returns first error', () {
      final ex = ValidationException(
        '입력값 오류',
        fieldErrors: {
          'email': ['이메일 형식이 올바르지 않습니다.'],
          'password': ['비밀번호는 8자 이상이어야 합니다.'],
        },
      );

      expect(ex.firstFieldError, '이메일 형식이 올바르지 않습니다.');
      expect(ex.code, 'validation_error');
    });

    test('ValidationException firstFieldError falls back to message', () {
      final ex = ValidationException('입력값 오류', fieldErrors: {});
      expect(ex.firstFieldError, '입력값 오류');
    });

    test('ValidationException firstFieldError skips empty lists', () {
      final ex = ValidationException(
        '입력값 오류',
        fieldErrors: {
          'email': [],
          'password': ['비밀번호 오류'],
        },
      );
      expect(ex.firstFieldError, '비밀번호 오류');
    });

    test('ServerException stores code', () {
      final ex = ServerException('서버 오류', statusCode: 500, code: 'internal_error');
      expect(ex.message, '서버 오류');
      expect(ex.statusCode, 500);
      expect(ex.code, 'internal_error');
    });

    test('AuthException stores custom code', () {
      final ex = AuthException('토큰 만료', 'token_expired');
      expect(ex.message, '토큰 만료');
      expect(ex.code, 'token_expired');
    });

    test('all exceptions extend AppException', () {
      expect(NetworkException(), isA<AppException>());
      expect(CacheException(), isA<AppException>());
      expect(ServerException('test'), isA<AppException>());
      expect(AuthException(), isA<AppException>());
      expect(RateLimitException(), isA<AppException>());
      expect(
        ValidationException('test', fieldErrors: {}),
        isA<AppException>(),
      );
    });

    test('RateLimitException default message', () {
      expect(RateLimitException().message, '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.');
    });

    test('ValidationException stores statusCode', () {
      final ex = ValidationException(
        '오류',
        fieldErrors: {'field': ['에러']},
        statusCode: 400,
      );
      expect(ex.statusCode, 400);
      expect(ex.fieldErrors.length, 1);
    });

    test('NetworkException default message', () {
      expect(NetworkException().message, '네트워크 연결을 확인해주세요.');
    });

    test('NetworkException custom message', () {
      expect(NetworkException('타임아웃').message, '타임아웃');
    });

    test('AppException toString returns message', () {
      final ex = AppException('커스텀 에러', statusCode: 500, code: 'custom');
      expect(ex.toString(), '커스텀 에러');
    });
  });
}
