import 'package:url_launcher/url_launcher.dart';

class SosService {
  static Future<bool> sendSos({
    required String phoneNumber,
    required double lat,
    required double lng,
    String? mountainName,
  }) async {
    final location = 'https://maps.google.com/?q=$lat,$lng';
    final suffix = mountainName != null ? ' ($mountainName에서 등산 중)' : '';
    final message = Uri.encodeComponent('긴급 SOS! 현재 위치: $location $suffix'.trim());
    final uri = Uri.parse('sms:$phoneNumber?body=$message');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
