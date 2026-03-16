import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            debugPrint('ApiClient token refresh error: $e');
          }
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<String?> _refreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return null;

    try {
      // 기존 _dio의 base options를 재사용하되 인터셉터 순환 방지를 위해 별도 인스턴스 사용
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>?;
      final newToken = data?['accessToken'] as String?;
      if (newToken == null) {
        await clearTokens();
        return null;
      }

      final newRefresh = data?['refreshToken'] as String?;
      await _storage.write(key: _tokenKey, value: newToken);
      if (newRefresh != null) {
        await _storage.write(key: _refreshTokenKey, value: newRefresh);
      }
      return newToken;
    } catch (e) {
      debugPrint('ApiClient._refreshToken error: $e');
      await clearTokens();
      return null;
    }
  }

  Future<void> setTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) {
      return AuthException();
    }
    return ServerException(
      e.response?.data?['message'] ?? '서버 오류가 발생했습니다.',
      statusCode: e.response?.statusCode,
    );
  }
}
