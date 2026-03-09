class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException([super.message = '네트워크 연결을 확인해주세요.']);
}

class CacheException extends AppException {
  CacheException([super.message = '로컬 데이터를 불러올 수 없습니다.']);
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});
}
