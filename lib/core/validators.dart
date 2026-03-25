/// 앱 전체에서 사용하는 입력 유효성 검증 유틸리티
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final _dangerousChars = RegExp('[<>"\u2018\u2019\u201C\u201D]');

  static String? email(String? value, {required String errorMessage}) {
    if (value == null || value.trim().isEmpty) return errorMessage;
    if (!_emailRegex.hasMatch(value.trim())) return errorMessage;
    return null;
  }

  static String? password(String? value, {required String errorMessage, int minLength = 6}) {
    if (value == null || value.length < minLength) return errorMessage;
    return null;
  }

  static String? nickname(String? value, {required String errorMessage, int minLength = 2, int maxLength = 20}) {
    if (value == null || value.trim().length < minLength) return errorMessage;
    if (value.trim().length > maxLength) return '$errorMessage ($maxLength자 이하)';
    return null;
  }

  static String? reviewContent(String? value, {required String errorMessage, int minLength = 5, int maxLength = 500}) {
    if (value == null || value.trim().length < minLength) return errorMessage;
    if (value.trim().length > maxLength) return '$errorMessage ($maxLength자 이하)';
    return null;
  }

  /// XSS 방지를 위한 입력 정제
  static String sanitize(String input) {
    return input.replaceAll(_dangerousChars, '');
  }
}
