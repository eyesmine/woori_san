import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/user.dart';
import 'package:woori_san/repositories/auth_repository.dart';
import 'package:woori_san/providers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  bool _hasToken = false;
  User? _user;
  bool shouldFail = false;

  @override
  Future<User> login(String email, String password) async {
    if (shouldFail) throw Exception('Login failed');
    _hasToken = true;
    _user = User(id: '1', email: email, nickname: '테스터');
    return _user!;
  }

  @override
  Future<User> signup(String email, String password, String nickname) async {
    if (shouldFail) throw Exception('Signup failed');
    _hasToken = true;
    _user = User(id: '2', email: email, nickname: nickname);
    return _user!;
  }

  @override
  Future<User> updateProfile({String? nickname, String? profileImageUrl}) async {
    if (_user == null) throw Exception('No user');
    _user = User(id: _user!.id, email: _user!.email, nickname: nickname ?? _user!.nickname);
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
    if (shouldFail) throw Exception('Register partner failed');
  }

  @override
  Future<void> removePartner() async {
    if (shouldFail) throw Exception('Remove partner failed');
  }
}

void main() {
  late AuthProvider provider;
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    provider = AuthProvider(fakeRepo);
  });

  group('AuthProvider', () {
    test('initial state is logged out', () {
      expect(provider.isLoggedIn, false);
      expect(provider.user, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('login success sets user and isLoggedIn', () async {
      final result = await provider.login('test@test.com', 'password');

      expect(result, true);
      expect(provider.isLoggedIn, true);
      expect(provider.user!.email, 'test@test.com');
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('login failure sets error', () async {
      fakeRepo.shouldFail = true;

      final result = await provider.login('test@test.com', 'password');

      expect(result, false);
      expect(provider.isLoggedIn, false);
      expect(provider.error, isNotNull);
      expect(provider.isLoading, false);
    });

    test('signup success sets user', () async {
      final result = await provider.signup('new@test.com', 'password', '새등산러');

      expect(result, true);
      expect(provider.isLoggedIn, true);
      expect(provider.user!.nickname, '새등산러');
    });

    test('signup failure sets error', () async {
      fakeRepo.shouldFail = true;

      final result = await provider.signup('new@test.com', 'password', '새등산러');

      expect(result, false);
      expect(provider.isLoggedIn, false);
      expect(provider.error, isNotNull);
    });

    test('logout clears user', () async {
      await provider.login('test@test.com', 'password');
      expect(provider.isLoggedIn, true);

      await provider.logout();

      expect(provider.isLoggedIn, false);
      expect(provider.user, isNull);
    });

    test('clearError clears error message', () async {
      fakeRepo.shouldFail = true;
      await provider.login('test@test.com', 'password');
      expect(provider.error, isNotNull);

      provider.clearError();

      expect(provider.error, isNull);
    });

    test('checkSession restores user if token exists', () async {
      // Login first to set token
      await provider.login('test@test.com', 'password');
      expect(provider.isLoggedIn, true);

      // Create new provider with same repo (simulating app restart)
      final newProvider = AuthProvider(fakeRepo);
      expect(newProvider.isLoggedIn, false);

      await newProvider.checkSession();

      expect(newProvider.isLoggedIn, true);
      expect(newProvider.user!.email, 'test@test.com');
    });

    test('checkSession does nothing without token', () async {
      await provider.checkSession();

      expect(provider.isLoggedIn, false);
    });
  });
}
