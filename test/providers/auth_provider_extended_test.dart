import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/exceptions.dart';
import 'package:woori_san/models/user.dart';
import 'package:woori_san/repositories/auth_repository.dart';
import 'package:woori_san/providers/auth_provider.dart';

/// Enhanced FakeAuthRepository that can throw specific exception types.
class FakeAuthRepository implements AuthRepository {
  bool _hasToken = false;
  User? _user;

  /// Set to a specific exception to throw on login.
  Exception? loginException;

  /// Set to a specific exception to throw on updateProfile.
  Exception? updateProfileException;

  /// Set to a specific exception to throw on registerPartner.
  Exception? registerPartnerException;

  /// Set to a specific exception to throw on removePartner.
  Exception? removePartnerException;

  @override
  Future<User> login(String email, String password) async {
    if (loginException != null) throw loginException!;
    _hasToken = true;
    _user = User(id: '1', email: email, nickname: '테스터');
    return _user!;
  }

  @override
  Future<User> signup(String email, String password, String nickname) async {
    _hasToken = true;
    _user = User(id: '2', email: email, nickname: nickname);
    return _user!;
  }

  @override
  Future<User> updateProfile({String? nickname, String? profileImageUrl}) async {
    if (updateProfileException != null) throw updateProfileException!;
    if (_user == null) throw Exception('No user');
    _user = User(
      id: _user!.id,
      email: _user!.email,
      nickname: nickname ?? _user!.nickname,
      profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
    );
    return _user!;
  }

  @override
  Future<User> getProfile() async {
    if (_user == null) throw Exception('No user');
    return _user!;
  }

  @override
  Future<void> logout() async {
    _hasToken = false;
    _user = null;
  }

  @override
  Future<bool> hasSession() async => _hasToken;

  @override
  Future<void> registerPartner(String partnerId) async {
    if (registerPartnerException != null) throw registerPartnerException!;
    // Simulate partner registration by updating the user
    if (_user != null) {
      _user = User(
        id: _user!.id,
        email: _user!.email,
        nickname: _user!.nickname,
        partnerId: partnerId,
        partnerNickname: '파트너',
      );
    }
  }

  @override
  Future<void> removePartner() async {
    if (removePartnerException != null) throw removePartnerException!;
    if (_user != null) {
      _user = User(
        id: _user!.id,
        email: _user!.email,
        nickname: _user!.nickname,
        partnerId: null,
        partnerNickname: null,
      );
    }
  }
}

void main() {
  late AuthProvider provider;
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    provider = AuthProvider(fakeRepo);
  });

  group('AuthProvider extended', () {
    group('updateProfile', () {
      test('success updates user nickname', () async {
        await provider.login('test@test.com', 'password');
        expect(provider.user!.nickname, '테스터');

        await provider.updateProfile(nickname: '새이름');

        expect(provider.user!.nickname, '새이름');
        expect(provider.error, isNull);
      });

      test('success updates profileImageUrl', () async {
        await provider.login('test@test.com', 'password');

        await provider.updateProfile(profileImageUrl: 'https://example.com/photo.jpg');

        expect(provider.user!.profileImageUrl, 'https://example.com/photo.jpg');
        expect(provider.error, isNull);
      });

      test('failure with NetworkException sets specific error', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.updateProfileException = NetworkException();
        await provider.updateProfile(nickname: '새이름');

        expect(provider.error, '네트워크 연결을 확인해주세요.');
        // User should remain unchanged
        expect(provider.user!.nickname, '테스터');
      });

      test('failure with generic exception sets generic error', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.updateProfileException = Exception('Server error');
        await provider.updateProfile(nickname: '새이름');

        expect(provider.error, '프로필 수정에 실패했습니다.');
      });

      test('does nothing when user is null', () async {
        expect(provider.user, isNull);

        await provider.updateProfile(nickname: '새이름');

        expect(provider.user, isNull);
        expect(provider.error, isNull);
      });
    });

    group('registerPartner', () {
      test('with empty id sets error and returns false', () async {
        await provider.login('test@test.com', 'password');

        final result = await provider.registerPartner('');

        expect(result, false);
        expect(provider.error, '파트너 ID를 입력해주세요.');
      });

      test('with whitespace-only id sets error and returns false', () async {
        await provider.login('test@test.com', 'password');

        final result = await provider.registerPartner('   ');

        expect(result, false);
        expect(provider.error, '파트너 ID를 입력해주세요.');
      });

      test('with too-long id (>255 chars) sets error and returns false', () async {
        await provider.login('test@test.com', 'password');

        final longId = 'a' * 256;
        final result = await provider.registerPartner(longId);

        expect(result, false);
        expect(provider.error, '파트너 ID가 너무 깁니다.');
      });

      test('with exactly 255 chars succeeds', () async {
        await provider.login('test@test.com', 'password');

        final exactId = 'a' * 255;
        final result = await provider.registerPartner(exactId);

        expect(result, true);
        expect(provider.error, isNull);
      });

      test('success returns true and refreshes user', () async {
        await provider.login('test@test.com', 'password');

        final result = await provider.registerPartner('partner123');

        expect(result, true);
        expect(provider.error, isNull);
        expect(provider.user, isNotNull);
      });

      test('failure with NetworkException sets network error', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.registerPartnerException = NetworkException();
        final result = await provider.registerPartner('partner123');

        expect(result, false);
        expect(provider.error, '네트워크 연결을 확인해주세요.');
      });

      test('failure with ValidationException uses firstFieldError', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.registerPartnerException = ValidationException(
          '유효성 검사 실패',
          fieldErrors: {
            'partner_id': ['존재하지 않는 사용자입니다.'],
          },
        );
        final result = await provider.registerPartner('partner123');

        expect(result, false);
        expect(provider.error, '존재하지 않는 사용자입니다.');
      });

      test('failure with generic exception sets generic error', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.registerPartnerException = Exception('Unknown error');
        final result = await provider.registerPartner('partner123');

        expect(result, false);
        expect(provider.error, '파트너 등록에 실패했습니다.');
      });
    });

    group('removePartner', () {
      test('success returns true and refreshes user', () async {
        await provider.login('test@test.com', 'password');
        await provider.registerPartner('partner123');

        final result = await provider.removePartner();

        expect(result, true);
        expect(provider.error, isNull);
      });

      test('failure with NetworkException sets network error', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.removePartnerException = NetworkException();
        final result = await provider.removePartner();

        expect(result, false);
        expect(provider.error, '네트워크 연결을 확인해주세요.');
      });

      test('failure with generic exception sets generic error', () async {
        await provider.login('test@test.com', 'password');

        fakeRepo.removePartnerException = Exception('Server error');
        final result = await provider.removePartner();

        expect(result, false);
        expect(provider.error, '파트너 해제에 실패했습니다.');
      });
    });

    group('login with specific exceptions', () {
      test('NetworkException sets network error message', () async {
        fakeRepo.loginException = NetworkException();

        final result = await provider.login('test@test.com', 'password');

        expect(result, false);
        expect(provider.error, '네트워크 연결을 확인해주세요.');
        expect(provider.isLoading, false);
      });

      test('RateLimitException sets its message', () async {
        fakeRepo.loginException =
            RateLimitException('1분 후 다시 시도해주세요.');

        final result = await provider.login('test@test.com', 'password');

        expect(result, false);
        expect(provider.error, '1분 후 다시 시도해주세요.');
        expect(provider.isLoading, false);
      });

      test('RateLimitException with default message', () async {
        fakeRepo.loginException = RateLimitException();

        final result = await provider.login('test@test.com', 'password');

        expect(result, false);
        expect(provider.error, '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.');
      });

      test('ValidationException uses firstFieldError', () async {
        fakeRepo.loginException = ValidationException(
          '유효성 검사 실패',
          fieldErrors: {
            'email': ['올바른 이메일 형식이 아닙니다.'],
            'password': ['비밀번호는 8자 이상이어야 합니다.'],
          },
        );

        final result = await provider.login('test@test.com', 'pw');

        expect(result, false);
        // firstFieldError returns the first error from the first field
        expect(provider.error, '올바른 이메일 형식이 아닙니다.');
      });

      test('ValidationException with empty field errors uses message', () async {
        fakeRepo.loginException = ValidationException(
          '유효성 검사 실패',
          fieldErrors: {},
        );

        final result = await provider.login('test@test.com', 'password');

        expect(result, false);
        expect(provider.error, '유효성 검사 실패');
      });

      test('AuthException sets its message', () async {
        fakeRepo.loginException = AuthException('이메일 또는 비밀번호가 일치하지 않습니다.');

        final result = await provider.login('test@test.com', 'wrong');

        expect(result, false);
        expect(provider.error, '이메일 또는 비밀번호가 일치하지 않습니다.');
      });

      test('generic exception sets fallback error message', () async {
        fakeRepo.loginException = Exception('Unexpected');

        final result = await provider.login('test@test.com', 'password');

        expect(result, false);
        expect(provider.error, '로그인에 실패했습니다.');
      });
    });
  });
}
