import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/validators.dart';

void main() {
  group('Validators.email', () {
    const err = '이메일 형식 오류';

    test('valid emails', () {
      expect(Validators.email('a@b.co', errorMessage: err), isNull);
      expect(Validators.email('test@gmail.com', errorMessage: err), isNull);
      expect(Validators.email('user.name+tag@example.kr', errorMessage: err), isNull);
    });

    test('invalid emails', () {
      expect(Validators.email(null, errorMessage: err), err);
      expect(Validators.email('', errorMessage: err), err);
      expect(Validators.email('noatsign', errorMessage: err), err);
      expect(Validators.email('a@', errorMessage: err), err);
      expect(Validators.email('@b.com', errorMessage: err), err);
    });
  });

  group('Validators.password', () {
    const err = '비밀번호 오류';

    test('valid passwords', () {
      expect(Validators.password('123456', errorMessage: err), isNull);
      expect(Validators.password('abcdefgh', errorMessage: err), isNull);
    });

    test('invalid passwords', () {
      expect(Validators.password(null, errorMessage: err), err);
      expect(Validators.password('', errorMessage: err), err);
      expect(Validators.password('12345', errorMessage: err), err);
    });

    test('custom min length', () {
      expect(Validators.password('1234', errorMessage: err, minLength: 4), isNull);
      expect(Validators.password('123', errorMessage: err, minLength: 4), err);
    });
  });

  group('Validators.nickname', () {
    const err = '닉네임 오류';

    test('valid nicknames', () {
      expect(Validators.nickname('ab', errorMessage: err), isNull);
      expect(Validators.nickname('등산왕', errorMessage: err), isNull);
    });

    test('too short', () {
      expect(Validators.nickname(null, errorMessage: err), err);
      expect(Validators.nickname('', errorMessage: err), err);
      expect(Validators.nickname('a', errorMessage: err), err);
    });

    test('too long', () {
      final long = 'a' * 21;
      expect(Validators.nickname(long, errorMessage: err, maxLength: 20), isNotNull);
    });
  });

  group('Validators.reviewContent', () {
    const err = '리뷰 오류';

    test('valid content', () {
      expect(Validators.reviewContent('좋은 산이에요!', errorMessage: err), isNull);
    });

    test('too short', () {
      expect(Validators.reviewContent(null, errorMessage: err), err);
      expect(Validators.reviewContent('짧음', errorMessage: err), err);
    });

    test('too long', () {
      final long = 'a' * 501;
      expect(Validators.reviewContent(long, errorMessage: err), isNotNull);
    });
  });

  group('Validators.sanitize', () {
    test('removes dangerous characters', () {
      expect(Validators.sanitize('<script>alert("xss")</script>'), 'scriptalert(xss)/script');
      expect(Validators.sanitize('normal text'), 'normal text');
      expect(Validators.sanitize("it\u2019s a test"), 'its a test');
    });

    test('preserves safe characters', () {
      expect(Validators.sanitize('한글 테스트 123!@#\$%'), '한글 테스트 123!@#\$%');
    });
  });
}
