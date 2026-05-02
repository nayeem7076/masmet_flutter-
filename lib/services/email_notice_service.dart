import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailNoticeService {
  // For Android emulator use: http://10.0.2.2:5000
  // For real phone use your PC/server IP, example: http://192.168.0.100:5000
  static const String baseUrl = 'http://10.0.2.2:5000';

  static Future<bool> sendNoticeEmail({
    required List<String> emails,
    required String title,
    required String message,
  }) async {
    if (emails.isEmpty) return false;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/send-notice-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'emails': emails,
              'title': title,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
