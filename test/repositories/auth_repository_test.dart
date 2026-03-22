import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/core/api_client.dart';
import 'package:woori_san/datasources/remote/auth_remote.dart';
import 'package:woori_san/models/user.dart';
import 'package:woori_san/repositories/auth_repository.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  User? profileUser;
  User? updatedUser;
  bool shouldFail = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (shouldFail) throw Exception('Login failed');
    // 백엔드는 access/refresh만 반환
    profileUser = User(id: '1', email: email, nickname: '테스터');
    return {
      'access': 'fake_access_token',
      'refresh': 'fake_refresh_token',
    };
  }

  @override
  Future<Map<String, dynamic>> signup(String email, String password, String nickname, {String? username}) async {
    if (shouldFail) throw Exception('Signup failed');
    // 백엔드는 user info만 반환 (토큰 없음)
    profileUser = User(id: '2', email: email, nickname: nickname);
    return {
      'email': email,
      'username': username ?? email.split('@').first,
      'nickname': nickname,
    };
  }

  @override
  Future<User> getProfile() async {
    if (shouldFail) throw Exception('Profile fetch failed');
    return profileUser ?? const User(id: '1', email: 'test@test.com', nickname: '테스터');
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('Update failed');
    updatedUser = User(
      id: '1',
      email: 'test@test.com',
      nickname: data['nickname'] ?? '테스터',
      profileImageUrl: data['profile_image'],
    );
    return updatedUser!;
  }

  @override
  Future<void> logout(String refreshToken) async {
    if (shouldFail) throw Exception('Logout failed');
  }

  @override
  Future<void> registerPartner(String partnerId) async {
    if (shouldFail) throw Exception('Partner register failed');
  }

  @override
  Future<void> removePartner() async {
    if (shouldFail) throw Exception('Partner remove failed');
  }
}

class FakeApiClient implements ApiClient {
  bool _hasToken = false;
  String? _accessToken;
  String? _refreshToken;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> setTokens({required String accessToken, String? refreshToken}) async {
    _hasToken = true;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _hasToken = false;
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<bool> hasToken() async => _hasToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;
}

void main() {
  late AuthRepository repo;
  late FakeAuthRemoteDataSource fakeRemote;
  late FakeApiClient fakeApiClient;

  setUp(() {
    fakeRemote = FakeAuthRemoteDataSource();
    fakeApiClient = FakeApiClient();
    repo = AuthRepository(fakeRemote, fakeApiClient);
  });

  group('AuthRepository', () {
    test('updateProfile calls remote and returns user', () async {
      final user = await repo.updateProfile(nickname: '새닉네임');

      expect(user.nickname, '새닉네임');
      expect(fakeRemote.updatedUser, isNotNull);
      expect(fakeRemote.updatedUser!.nickname, '새닉네임');
    });

    test('updateProfile with profileImageUrl', () async {
      final user = await repo.updateProfile(
        nickname: '등산러',
        profileImageUrl: 'https://example.com/photo.jpg',
      );

      expect(user.nickname, '등산러');
      expect(user.profileImageUrl, 'https://example.com/photo.jpg');
    });

    test('hasSession returns false when no token set', () async {
      final result = await repo.hasSession();

      expect(result, false);
    });

    test('hasSession returns true after login', () async {
      await repo.login('test@test.com', 'password');

      final result = await repo.hasSession();

      expect(result, true);
    });

    test('hasSession returns false after logout', () async {
      await repo.login('test@test.com', 'password');
      expect(await repo.hasSession(), true);

      await repo.logout();

      expect(await repo.hasSession(), false);
    });

    test('login sets tokens on apiClient', () async {
      await repo.login('test@test.com', 'password');

      expect(fakeApiClient._hasToken, true);
      expect(fakeApiClient._accessToken, 'fake_access_token');
      expect(fakeApiClient._refreshToken, 'fake_refresh_token');
    });

    test('login returns user from remote data', () async {
      final user = await repo.login('test@test.com', 'password');

      expect(user.email, 'test@test.com');
      expect(user.nickname, '테스터');
    });

    test('getProfile returns user from remote', () async {
      fakeRemote.profileUser = const User(id: '1', email: 'user@test.com', nickname: '프로필유저');

      final user = await repo.getProfile();

      expect(user.email, 'user@test.com');
      expect(user.nickname, '프로필유저');
    });
  });
}
