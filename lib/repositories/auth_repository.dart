import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../datasources/remote/auth_remote.dart';
import '../models/user.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote;
  final ApiClient _apiClient;

  AuthRepository(this._remote, this._apiClient);

  /// 로그인: 토큰 저장 → 프로필 조회
  Future<User> login(String email, String password) async {
    final data = await _remote.login(email, password);
    debugPrint('AuthRepository.login response keys: ${data.keys.toList()}');
    // Django Simple JWT: access/refresh 또는 token 키
    final accessToken = (data['access'] ?? data['token'] ?? data['accessToken']) as String?;
    final refreshToken = (data['refresh'] ?? data['refreshToken']) as String?;
    if (accessToken == null) {
      debugPrint('AuthRepository.login response data: $data');
      throw AuthException('서버 응답에 토큰이 없습니다.');
    }
    await _apiClient.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    return await _remote.getProfile();
  }

  /// 회원가입: 계정 생성 → 자동 로그인
  Future<User> signup(String email, String password, String nickname) async {
    await _remote.signup(email, password, nickname);
    // 가입 응답에 토큰이 없으므로 자동 로그인
    try {
      return await login(email, password);
    } catch (e) {
      debugPrint('AuthRepository.signup auto-login error: $e');
      rethrow;
    }
  }

  Future<User> getProfile() async {
    return await _remote.getProfile();
  }

  Future<User> updateProfile({String? nickname, String? profileImageUrl}) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (profileImageUrl != null) data['profile_image'] = profileImageUrl;
    return await _remote.updateProfile(data);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } catch (e) {
      // 서버 로그아웃 실패해도 로컬 토큰은 삭제
      debugPrint('AuthRepository.logout server error (ignored): $e');
    }
    await _apiClient.clearTokens();
  }

  Future<bool> hasSession() async {
    return await _apiClient.hasToken();
  }

  Future<void> registerPartner(String partnerId) async {
    await _remote.registerPartner(partnerId);
  }

  Future<void> removePartner() async {
    await _remote.removePartner();
  }
}
