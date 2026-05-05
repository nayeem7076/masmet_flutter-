import 'package:flutter/material.dart';

import 'package:messmate_app_full/features/notices/data/models/notice.dart';
import 'package:messmate_app_full/features/notices/data/services/notice_service.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
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
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDetails(NoticeItem item) async {
    try {
      final notice = await NoticeService.getNoticeById(item.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(notice.title),
          content: SingleChildScrollView(
            child: Text(notice.text.isEmpty ? 'No details found.' : notice.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
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
        title: const Text('Notice'),
        actions: [
          IconButton(
            onPressed: _loadNotices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _notices.isEmpty
                  ? const Center(child: Text('No notice found'))
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
