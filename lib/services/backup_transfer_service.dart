import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BackupTransferService {
  static Future<void> shareViaWhatsApp({
    required String message,
    String? filePath,
  }) async {
    if (filePath != null && filePath.isNotEmpty) {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: message,
      );
      return;
    }

    final url = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    );
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened) {
      throw Exception('Could not open WhatsApp share link.');
    }
  }
}
