import '../../core/api_client.dart';
import '../../models/user.dart';

class AuthRemoteDataSource {
  final ApiClient api;

  AuthRemoteDataSource(this.api);

  /// POST /api/auth/login/ → {access, refresh}
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw FormatException('Unexpected login response type: ${data.runtimeType}');
  }

  /// POST /api/auth/register/ → {email, username, nickname}
  Future<Map<String, dynamic>> signup(String email, String password, String nickname, {String? username}) async {
    final response = await api.post('/auth/register/', data: {
      'email': email,
      'password': password,
      'nickname': nickname,
      'username': username ?? email.split('@').first,
    });
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw FormatException('Unexpected signup response type: ${data.runtimeType}');
  }

  /// GET /api/auth/me/
  Future<User> getProfile() async {
    final response = await api.get('/auth/me/');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/auth/me/
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await api.patch('/auth/me/', data: data);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/auth/logout/ — Refresh Token 블랙리스트
  Future<void> logout(String refreshToken) async {
    await api.post('/auth/logout/', data: {
      'refresh': refreshToken,
    });
  }

  /// POST /api/auth/partner/ — 파트너 등록
  Future<void> registerPartner(String partnerId) async {
    await api.post('/auth/partner/', data: {
      'partner_id': partnerId,
    });
  }

  /// DELETE /api/auth/partner/ — 파트너 해제
  Future<void> removePartner() async {
    await api.delete('/auth/partner/');
  }
}
