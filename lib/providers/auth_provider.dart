import 'package:flutter/material.dart';
import '../core/exceptions.dart';
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
        debugPrint('AuthProvider.checkSession error: $e');
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
      _isLoading = false;
      notifyListeners();
      return true;
    } on RateLimitException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ValidationException catch (e) {
      _error = e.firstFieldError;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String nickname) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.signup(email, password, nickname);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException {
      // 가입은 성공했지만 자동 로그인 실패 → 가입 성공 처리 (로그인 화면에서 직접 로그인)
      _isLoading = false;
      notifyListeners();
      return true;
    } on RateLimitException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ValidationException catch (e) {
      _error = e.firstFieldError;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> registerPartner(String partnerId) async {
    try {
      await _repo.registerPartner(partnerId);
      _user = await _repo.getProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePartner() async {
    try {
      await _repo.removePartner();
      _user = await _repo.getProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
