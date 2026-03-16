import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/exceptions.dart';

void main() {
  group('Exceptions', () {
    test('AppException stores message and statusCode', () {
      final ex = AppException('에러 발생', statusCode: 500);
      expect(ex.message, '에러 발생');
      expect(ex.statusCode, 500);
      expect(ex.toString(), contains('500'));
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
  });
}
