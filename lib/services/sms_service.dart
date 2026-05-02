import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static Future<bool> composeSms({
    required List<String> recipients,
    required String message,
  }) async {
    if (recipients.isEmpty) return false;

    final cleanedRecipients = recipients
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toSet()
        .toList();

    if (cleanedRecipients.isEmpty) return false;

    final uri = Uri(
      scheme: 'sms',
      path: cleanedRecipients.join(','),
      queryParameters: <String, String>{
        'body': message,
      },
    );

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
