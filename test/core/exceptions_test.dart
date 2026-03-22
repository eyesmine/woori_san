import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/exceptions.dart';

void main() {
  group('Exceptions', () {
    test('AppException stores message and statusCode', () {
      final ex = AppException('에러 발생', statusCode: 500);
      expect(ex.message, '에러 발생');
      expect(ex.statusCode, 500);
      expect(ex.toString(), '에러 발생');
    });

    test('NetworkException has default message', () {
      final ex = NetworkException();
      expect(ex.message, '네트워크 연결을 확인해주세요.');
    });

    test('CacheException has default message', () {
      final ex = CacheException();
      expect(ex.message, '로컬 데이터를 불러올 수 없습니다.');
    });

    test('ServerException stores custom message and statusCode', () {
      final ex = ServerException('서버 점검 중', statusCode: 503);
      expect(ex.message, '서버 점검 중');
      expect(ex.statusCode, 503);
    });

    test('AuthException has default message', () {
      final ex = AuthException();
      expect(ex.message, '인증에 실패했습니다.');
    });

    test('all exceptions implement Exception', () {
      expect(NetworkException(), isA<Exception>());
      expect(CacheException(), isA<Exception>());
      expect(ServerException('test'), isA<Exception>());
      expect(AuthException(), isA<Exception>());
    });

    test('ValidationException stores fieldErrors and has correct code', () {
      final ex = ValidationException(
        '유효성 검사 실패',
        fieldErrors: {
          'email': ['이메일 형식이 올바르지 않습니다.'],
          'password': ['비밀번호는 8자 이상이어야 합니다.', '특수문자를 포함해야 합니다.'],
        },
        statusCode: 400,
      );

      expect(ex.message, '유효성 검사 실패');
      expect(ex.code, 'validation_error');
      expect(ex.statusCode, 400);
      expect(ex.fieldErrors.length, 2);
      expect(ex.fieldErrors['email']!.first, '이메일 형식이 올바르지 않습니다.');
      expect(ex.fieldErrors['password']!.length, 2);
    });

    test('ValidationException.firstFieldError returns first available error', () {
      final ex = ValidationException(
        '오류',
        fieldErrors: {'field': ['첫 번째 에러']},
      );
      expect(ex.firstFieldError, '첫 번째 에러');
    });

    test('ValidationException.firstFieldError returns message when empty', () {
      final ex = ValidationException(
        '폴백 메시지',
        fieldErrors: {},
      );
      expect(ex.firstFieldError, '폴백 메시지');
    });

    test('AuthException accepts custom code', () {
      final ex = AuthException('세션 만료', 'session_expired');
      expect(ex.message, '세션 만료');
      expect(ex.code, 'session_expired');
    });

    test('ServerException accepts code parameter', () {
      final ex = ServerException('내부 오류', statusCode: 500, code: 'internal');
      expect(ex.code, 'internal');
      expect(ex.statusCode, 500);
    });

    test('RateLimitException has default message', () {
      final ex = RateLimitException();
      expect(ex.message, '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.');
    });

    test('RateLimitException accepts custom message', () {
      final ex = RateLimitException('1분 후 다시 시도하세요.');
      expect(ex.message, '1분 후 다시 시도하세요.');
    });

    test('RateLimitException is AppException', () {
      expect(RateLimitException(), isA<AppException>());
    });
  });
}
