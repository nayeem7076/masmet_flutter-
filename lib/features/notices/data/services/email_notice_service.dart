import 'package:messmate_app_full/core/constants/app_constants.dart';
import 'package:messmate_app_full/core/network/api_client.dart';

class EmailNoticeService {
  static Future<bool> sendNoticeEmail({
    required List<String> emails,
    required String title,
    required String message,
  }) async {
    if (emails.isEmpty) return false;

    try {
      await ApiClient.postJson(
        ApiRoutes.sendNoticeEmail,
        body: {
          'emails': emails,
          'title': title,
          'message': message,
        },
        requiresAuth: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
