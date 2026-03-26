import 'package:flutter/material.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._repo);

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkSession() async {
    final hasSession = await _repo.hasSession();
    if (hasSession) {
      try {
        _user = await _repo.getProfile();
        notifyListeners();
      } catch (e) {
        AppLogger.warning('세션 복원 실패, 로그아웃 처리', tag: 'AuthProvider', error: e);
        await _repo.logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.login(email, password);
      return true;
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } on RateLimitException catch (e) {
      _error = e.message;
    } on ValidationException catch (e) {
      _error = e.firstFieldError;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '로그인에 실패했습니다.';
      AppLogger.error('login 실패', tag: 'AuthProvider', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> signup(String email, String password, String nickname) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.signup(email, password, nickname);
      return true;
    } on AuthException {
      // 가입은 성공했지만 자동 로그인 실패 → 가입 성공 처리 (로그인 화면에서 직접 로그인)
      return true;
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } on RateLimitException catch (e) {
      _error = e.message;
    } on ValidationException catch (e) {
      _error = e.firstFieldError;
    } catch (e) {
      _error = '회원가입에 실패했습니다.';
      AppLogger.error('signup 실패', tag: 'AuthProvider', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> updateProfile({String? nickname, String? profileImageUrl}) async {
    if (_user == null) return;
    try {
      final updated = await _repo.updateProfile(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
      );
      _user = updated;
      notifyListeners();
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
      notifyListeners();
    } catch (e) {
      _error = '프로필 수정에 실패했습니다.';
      AppLogger.error('updateProfile 실패', tag: 'AuthProvider', error: e);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> registerPartner(String partnerId) async {
    final trimmedId = partnerId.trim();
    if (trimmedId.isEmpty) {
      _error = '파트너 ID를 입력해주세요.';
      notifyListeners();
      return false;
    }
    if (trimmedId.length > 255) {
      _error = '파트너 ID가 너무 깁니다.';
      notifyListeners();
      return false;
    }
    try {
      await _repo.registerPartner(trimmedId);
      _user = await _repo.getProfile();
      notifyListeners();
      return true;
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } on ValidationException catch (e) {
      _error = e.firstFieldError;
    } catch (e) {
      _error = '파트너 등록에 실패했습니다.';
      AppLogger.error('registerPartner 실패', tag: 'AuthProvider', error: e);
    }
    notifyListeners();
    return false;
  }

  Future<bool> removePartner() async {
    try {
      await _repo.removePartner();
      _user = await _repo.getProfile();
      notifyListeners();
      return true;
    } on NetworkException {
      _error = '네트워크 연결을 확인해주세요.';
    } catch (e) {
      _error = '파트너 해제에 실패했습니다.';
      AppLogger.error('removePartner 실패', tag: 'AuthProvider', error: e);
    }
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
