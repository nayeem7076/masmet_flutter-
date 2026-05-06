import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/core/ui/ui_feedback.dart';
import 'package:messmate_app_full/features/notices/data/models/notice.dart';
import 'package:messmate_app_full/features/notices/data/services/notice_service.dart';

class NoticeScreen extends ConsumerStatefulWidget {
  const NoticeScreen({super.key});

  @override
  ConsumerState<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends ConsumerState<NoticeScreen> {
  List<NoticeItem> _notices = <NoticeItem>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notices = await NoticeService.getAllNotices();
      if (!mounted) return;
      setState(() => _notices = notices);
    } catch (e) {
      if (!mounted) return;
      final localNotices =
          ref.read(appProviderProvider).visibleNoticesForCurrentUser();
      setState(() {
        _notices = localNotices;
        if (localNotices.isEmpty) {
          _error = e.toString().replaceFirst('Exception: ', '');
        } else {
          _error = null;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDetails(NoticeItem item) async {
    try {
      final notice = await AppLoader.run<NoticeItem>(
        context: context,
        message: AppText.t(context,
            bn: 'নোটিশ লোড হচ্ছে...', en: 'Loading notice...'),
        task: () async {
          if (item.id.isNotEmpty) {
            return NoticeService.getNoticeById(item.id);
          }
          return item;
        },
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(notice.title),
          content: SingleChildScrollView(
            child: Text(
              notice.text.isEmpty
                  ? AppText.t(context,
                      bn: 'বিস্তারিত পাওয়া যায়নি।', en: 'No details found.')
                  : notice.text,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppText.t(context, bn: 'বন্ধ', en: 'Close')),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t(context, bn: 'নোটিশ', en: 'Notice')),
        actions: [
          IconButton(
            onPressed: () => AppLoader.run<void>(
              context: context,
              message: AppText.t(context,
                  bn: 'নোটিশ রিফ্রেশ হচ্ছে...', en: 'Refreshing notices...'),
              task: _loadNotices,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _notices.isEmpty
                  ? Center(
                      child: Text(
                        AppText.t(context,
                            bn: 'কোনো নোটিশ পাওয়া যায়নি',
                            en: 'No notice found'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotices,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _notices.length,
                        itemBuilder: (context, index) {
                          final notice = _notices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => _openDetails(notice),
                              leading: const CircleAvatar(
                                child: Icon(Icons.campaign),
                              ),
                              title: Text(notice.title),
                              subtitle: Text(
                                notice.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
