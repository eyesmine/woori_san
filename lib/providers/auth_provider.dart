import 'package:flutter/material.dart';
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
      } catch (_) {
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
