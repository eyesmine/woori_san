import 'package:url_launcher/url_launcher.dart';

class SosService {
  static Future<bool> sendSos({
    required String phoneNumber,
    required double lat,
    required double lng,
    String? mountainName,
  }) async {
    final message = Uri.encodeComponent(
      '긴급 SOS! 현재 위치: https://maps.google.com/?q=$lat,$lng'
      '${mountainName != null ? ' ($mountainName에서 등산 중)' : ''}',
    );
    final uri = Uri.parse('sms:$phoneNumber?body=$message');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
