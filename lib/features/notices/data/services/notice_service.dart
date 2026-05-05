import 'package:messmate_app_full/core/constants/app_constants.dart';
import 'package:messmate_app_full/core/network/api_client.dart';
import 'package:messmate_app_full/features/notices/data/models/notice.dart';

class NoticeService {
  static Future<List<NoticeItem>> getAllNotices() async {
    final json = await ApiClient.get(ApiRoutes.notices);
    final raw = json['data'] ?? json['notices'] ?? json;

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => NoticeItem.fromApi(item.cast<String, dynamic>()))
          .toList();
    }
    return <NoticeItem>[];
  }

  static Future<NoticeItem> getNoticeById(String id) async {
    final json = await ApiClient.get('${ApiRoutes.notices}/$id');
    final raw = json['data'] ?? json['notice'] ?? json;
    if (raw is Map<String, dynamic>) {
      return NoticeItem.fromApi(raw);
    }
    if (raw is Map) {
      return NoticeItem.fromApi(raw.cast<String, dynamic>());
    }
    throw ApiException('Invalid notice response.');
  }
}
