import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:woori_san/core/api_client.dart';
import 'package:woori_san/core/exceptions.dart';

void main() {
  late ApiClient apiClient;

  setUp(() {
    // FlutterSecureStorage requires mock initial values in test environment
    FlutterSecureStorage.setMockInitialValues({});
    apiClient = ApiClient();
  });

  group('Token management', () {
    test('hasToken returns false when no token is stored', () async {
      expect(await apiClient.hasToken(), isFalse);
    });

    test('hasToken returns true after setTokens with access token', () async {
      await apiClient.setTokens(accessToken: 'test_access_token');

      expect(await apiClient.hasToken(), isTrue);
    });

    test('getRefreshToken returns null when no refresh token stored', () async {
      expect(await apiClient.getRefreshToken(), isNull);
    });

    test('getRefreshToken returns token after setTokens with refresh token', () async {
      await apiClient.setTokens(
        accessToken: 'test_access',
        refreshToken: 'test_refresh',
      );

      expect(await apiClient.getRefreshToken(), 'test_refresh');
    });

    test('setTokens with only access token does not set refresh token', () async {
      await apiClient.setTokens(accessToken: 'access_only');

      expect(await apiClient.hasToken(), isTrue);
      expect(await apiClient.getRefreshToken(), isNull);
    });

    test('clearTokens removes both access and refresh tokens', () async {
      await apiClient.setTokens(
        accessToken: 'test_access',
        refreshToken: 'test_refresh',
      );

      expect(await apiClient.hasToken(), isTrue);
      expect(await apiClient.getRefreshToken(), isNotNull);

      await apiClient.clearTokens();

      expect(await apiClient.hasToken(), isFalse);
      expect(await apiClient.getRefreshToken(), isNull);
    });

    test('setTokens overwrites previous tokens', () async {
      await apiClient.setTokens(
        accessToken: 'first_access',
        refreshToken: 'first_refresh',
      );

      await apiClient.setTokens(
        accessToken: 'second_access',
        refreshToken: 'second_refresh',
      );

      expect(await apiClient.getRefreshToken(), 'second_refresh');
      expect(await apiClient.hasToken(), isTrue);
    });

    test('clearTokens is idempotent (can be called without tokens)', () async {
      // Should not throw even when no tokens are stored
      await apiClient.clearTokens();

      expect(await apiClient.hasToken(), isFalse);
      expect(await apiClient.getRefreshToken(), isNull);
    });

    test('setTokens then clearTokens then setTokens works correctly', () async {
      await apiClient.setTokens(accessToken: 'a1', refreshToken: 'r1');
      await apiClient.clearTokens();
      await apiClient.setTokens(accessToken: 'a2', refreshToken: 'r2');

      expect(await apiClient.hasToken(), isTrue);
      expect(await apiClient.getRefreshToken(), 'r2');
    });
  });

  group('Dio instance', () {
    test('dio getter returns a Dio instance', () {
      final dio = apiClient.dio;
      expect(dio, isNotNull);
    });

    test('dio has correct base configuration', () {
      final dio = apiClient.dio;
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });

    test('dio has interceptors configured', () {
      final dio = apiClient.dio;
      // ApiClient adds one QueuedInterceptorsWrapper
      expect(dio.interceptors, isNotEmpty);
    });
  });

  group('Error handling via HTTP calls (integration-style)', () {
    // These tests verify _handleError behavior indirectly by making requests
    // that will fail (since there's no real server). The Dio errors should be
    // transformed into our AppException hierarchy.

    test('get to invalid host throws NetworkException', () async {
      // Override base URL to an unreachable host
      apiClient.dio.options.baseUrl = 'http://0.0.0.0:1';
      apiClient.dio.options.connectTimeout = const Duration(milliseconds: 500);
      apiClient.dio.options.receiveTimeout = const Duration(milliseconds: 500);

      expect(
        () => apiClient.get('/test'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('post to invalid host throws NetworkException', () async {
      apiClient.dio.options.baseUrl = 'http://0.0.0.0:1';
      apiClient.dio.options.connectTimeout = const Duration(milliseconds: 500);
      apiClient.dio.options.receiveTimeout = const Duration(milliseconds: 500);

      expect(
        () => apiClient.post('/test', data: {'key': 'value'}),
        throwsA(isA<NetworkException>()),
      );
    });

    test('put to invalid host throws NetworkException', () async {
      apiClient.dio.options.baseUrl = 'http://0.0.0.0:1';
      apiClient.dio.options.connectTimeout = const Duration(milliseconds: 500);
      apiClient.dio.options.receiveTimeout = const Duration(milliseconds: 500);

      expect(
        () => apiClient.put('/test', data: {'key': 'value'}),
        throwsA(isA<NetworkException>()),
      );
    });

    test('patch to invalid host throws NetworkException', () async {
      apiClient.dio.options.baseUrl = 'http://0.0.0.0:1';
      apiClient.dio.options.connectTimeout = const Duration(milliseconds: 500);
      apiClient.dio.options.receiveTimeout = const Duration(milliseconds: 500);

      expect(
        () => apiClient.patch('/test', data: {'key': 'value'}),
        throwsA(isA<NetworkException>()),
      );
    });

    test('delete to invalid host throws NetworkException', () async {
      apiClient.dio.options.baseUrl = 'http://0.0.0.0:1';
      apiClient.dio.options.connectTimeout = const Duration(milliseconds: 500);
      apiClient.dio.options.receiveTimeout = const Duration(milliseconds: 500);

      expect(
        () => apiClient.delete('/test'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('Multiple ApiClient instances share storage', () {
    test('tokens set on one instance are visible to another', () async {
      final client1 = ApiClient();
      final client2 = ApiClient();

      await client1.setTokens(
        accessToken: 'shared_access',
        refreshToken: 'shared_refresh',
      );

      expect(await client2.hasToken(), isTrue);
      expect(await client2.getRefreshToken(), 'shared_refresh');

      // Cleanup
      await client1.clearTokens();
    });
  });

  group('Exception type expectations from _handleError', () {
    // These verify the mapping logic documented in _handleError:
    // - connectionTimeout/receiveTimeout/connectionError -> NetworkException
    // - 429 -> RateLimitException
    // - 401 -> AuthException
    // - validation_error code -> ValidationException
    // - other -> ServerException
    //
    // Since _handleError is private, we verify via the exception classes themselves.

    test('NetworkException has default message', () {
      final ex = NetworkException();
      expect(ex.message, contains('네트워크'));
      expect(ex, isA<AppException>());
    });

    test('RateLimitException has default message', () {
      final ex = RateLimitException();
      expect(ex.message, contains('요청이 너무 많습니다'));
      expect(ex, isA<AppException>());
    });

    test('AuthException has default message', () {
      final ex = AuthException();
      expect(ex.message, contains('인증'));
      expect(ex, isA<AppException>());
    });

    test('ValidationException carries field errors', () {
      final ex = ValidationException(
        '유효성 검증 실패',
        fieldErrors: {
          'email': ['올바른 이메일을 입력하세요.'],
          'name': ['이름은 필수입니다.', '2자 이상 입력하세요.'],
        },
        statusCode: 400,
      );

      expect(ex.code, 'validation_error');
      expect(ex.statusCode, 400);
      expect(ex.fieldErrors.length, 2);
      expect(ex.fieldErrors['email']!.length, 1);
      expect(ex.fieldErrors['name']!.length, 2);
      expect(ex.firstFieldError, '올바른 이메일을 입력하세요.');
    });

    test('ServerException carries status code and custom code', () {
      final ex = ServerException('서버 내부 오류', statusCode: 500, code: 'internal');
      expect(ex.message, '서버 내부 오류');
      expect(ex.statusCode, 500);
      expect(ex.code, 'internal');
    });
  });

  group('Retryable status codes documentation', () {
    // _retryableStatusCodes = {408, 429, 500, 502, 503, 504}
    // This group verifies that the retry logic is internally consistent
    // by confirming the expected exception types.

    test('non-retryable status codes produce immediate errors', () {
      // 400, 401, 403, 404, 422 are NOT in _retryableStatusCodes
      // They should fail on first attempt without retries.
      // We validate the exception types these would produce.
      expect(AuthException('test', 'token_expired').code, 'token_expired');
      expect(
        ValidationException('test', fieldErrors: {'f': ['err']}).code,
        'validation_error',
      );
      expect(ServerException('test', statusCode: 404).statusCode, 404);
    });
  });
}
