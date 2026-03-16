import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../datasources/remote/auth_remote.dart';
import '../models/user.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote;
  final ApiClient _apiClient;

  AuthRepository(this._remote, this._apiClient);

  Future<User> login(String email, String password) async {
    final data = await _remote.login(email, password);
    final accessToken = data['accessToken'] as String?;
    if (accessToken == null) {
      throw AuthException('서버 응답에 토큰이 없습니다.');
    }
    await _apiClient.setTokens(
      accessToken: accessToken,
      refreshToken: data['refreshToken'] as String?,
    );
    return User.fromJson(data['user']);
  }

  Future<User> signup(String email, String password, String nickname) async {
    final data = await _remote.signup(email, password, nickname);
    final accessToken = data['accessToken'] as String?;
    if (accessToken == null) {
      throw AuthException('서버 응답에 토큰이 없습니다.');
    }
    await _apiClient.setTokens(
      accessToken: accessToken,
      refreshToken: data['refreshToken'] as String?,
    );
    return User.fromJson(data['user']);
  }

  Future<User> getProfile() async {
    return await _remote.getProfile();
  }

  Future<User> updateProfile({String? nickname, String? profileImageUrl}) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
    return await _remote.updateProfile(data);
  }

  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  Future<bool> hasSession() async {
    return await _apiClient.hasToken();
  }
}
