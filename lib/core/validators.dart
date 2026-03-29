/// 앱 전체에서 사용하는 입력 유효성 검증 유틸리티
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static String? email(String? value, {required String errorMessage}) {
    if (value == null || value.trim().isEmpty) return errorMessage;
    if (!_emailRegex.hasMatch(value.trim())) return errorMessage;
    return null;
  }

  static String? password(String? value, {required String errorMessage, int minLength = 8}) {
    if (value == null || value.length < minLength) return errorMessage;
    // 최소 1개 영문 + 1개 숫자
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) return errorMessage;
    if (!RegExp(r'[0-9]').hasMatch(value)) return errorMessage;
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

  /// API 전송용 입력 정제 — 위험 문자를 제거 (HTML 이스케이프가 아닌 제거)
  static String sanitize(String input) {
    return input.replaceAll(RegExp('[<>]'), '');
  }

  /// 화면 표시용 HTML 이스케이프 (WebView 등에서 사용)
  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
