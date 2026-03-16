import '../../core/api_client.dart';
import '../../models/user.dart';

class AuthRemoteDataSource {
  final ApiClient api;

  AuthRemoteDataSource(this.api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> signup(String email, String password, String nickname) async {
    final response = await api.post('/auth/register', data: {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<User> getProfile() async {
    final response = await api.get('/auth/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await api.put('/auth/profile', data: data);
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
