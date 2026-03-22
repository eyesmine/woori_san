class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  AppException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([super.message = '네트워크 연결을 확인해주세요.']);
}

class CacheException extends AppException {
  CacheException([super.message = '로컬 데이터를 불러올 수 없습니다.']);
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode, super.code});
}

class AuthException extends AppException {
  AuthException([super.message = '인증에 실패했습니다.', String? code])
      : super(code: code);
}

class RateLimitException extends AppException {
  RateLimitException([super.message = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.']);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  ValidationException(super.message, {required this.fieldErrors, super.statusCode})
      : super(code: 'validation_error');

  /// 첫 번째 필드 에러 메시지
  String get firstFieldError {
    for (final errors in fieldErrors.values) {
      if (errors.isNotEmpty) return errors.first;
    }
    return message;
  }
}
