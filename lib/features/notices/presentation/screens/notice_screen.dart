import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/core/ui/ui_feedback.dart';
import 'package:messmate_app_full/features/notices/data/models/notice.dart';

class NoticeScreen extends ConsumerStatefulWidget {
  const NoticeScreen({super.key});

  @override
  ConsumerState<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends ConsumerState<NoticeScreen> {
  List<NoticeItem> _notices = <NoticeItem>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _loading = true;
    });
    final localNotices = ref.read(appProviderProvider).visibleNoticesForCurrentUser()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() {
      _notices = localNotices;
      _loading = false;
    });
  }

  Future<void> _openDetails(NoticeItem item) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Text(
            item.text.isEmpty
                ? AppText.t(
                    context,
                    bn: 'বিস্তারিত পাওয়া যায়নি।',
                    en: 'No details found.',
                  )
                : item.text,
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
  }

  Future<void> _showCreateNoticeSheet() async {
    final provider = ref.read(appProviderProvider);
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    bool sendToAll = true;
    final selectedMemberIds = <String>{};
    bool sendEmail = true;
    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final members = provider.members;
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_alert_rounded, color: Color(0xFF2F5DFF)),
                            const SizedBox(width: 8),
                            Text(
                              AppText.t(context, bn: 'নোটিশ দিন', en: 'Create Notice'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: titleController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: AppText.t(context, bn: 'শিরোনাম', en: 'Title'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: AppText.t(context, bn: 'বিস্তারিত', en: 'Message'),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(AppText.t(context, bn: 'সবার জন্য', en: 'For All')),
                              icon: const Icon(Icons.groups_rounded),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(
                                AppText.t(context, bn: 'নির্দিষ্ট মেম্বার', en: 'Specific'),
                              ),
                              icon: const Icon(Icons.person_pin_rounded),
                            ),
                          ],
                          selected: <bool>{sendToAll},
                          onSelectionChanged: (selection) {
                            setModalState(() {
                              sendToAll = selection.first;
                              if (sendToAll) selectedMemberIds.clear();
                            });
                          },
                        ),
                        if (!sendToAll) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: members.map((member) {
                              final selected = selectedMemberIds.contains(member.id);
                              return FilterChip(
                                label: Text(member.name),
                                selected: selected,
                                onSelected: (value) {
                                  setModalState(() {
                                    if (value) {
                                      selectedMemberIds.add(member.id);
                                    } else {
                                      selectedMemberIds.remove(member.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: sendEmail,
                          onChanged: (value) {
                            setModalState(() => sendEmail = value);
                          },
                          title: Text(
                            AppText.t(
                              context,
                              bn: 'ইমেইলে পাঠান',
                              en: 'Send Email',
                            ),
                          ),
                          subtitle: Text(
                            AppText.t(
                              context,
                              bn: 'নোটিশ সেভের সাথে ইমেইল পাঠানোর চেষ্টা করবে',
                              en: 'Try sending notice by email after save',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: saving ? null : () => Navigator.pop(sheetContext),
                                child: Text(AppText.t(context, bn: 'বাতিল', en: 'Cancel')),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: saving
                                    ? null
                                    : () async {
                                        final title = titleController.text.trim();
                                        final text = messageController.text.trim();
                                        if (title.isEmpty || text.isEmpty) {
                                          UiFeedback.showError(
                                            context,
                                            AppText.t(
                                              context,
                                              bn: 'শিরোনাম ও বিস্তারিত দিন',
                                              en: 'Please enter title and message',
                                            ),
                                          );
                                          return;
                                        }
                                        if (!sendToAll && selectedMemberIds.isEmpty) {
                                          UiFeedback.showError(
                                            context,
                                            AppText.t(
                                              context,
                                              bn: 'অন্তত একজন মেম্বার নির্বাচন করুন',
                                              en: 'Select at least one member',
                                            ),
                                          );
                                          return;
                                        }
                                        setModalState(() => saving = true);
                                        await provider.addNotice(
                                          title: title,
                                          text: text,
                                          sendToAll: sendToAll,
                                          targetMemberIds: selectedMemberIds.toList(),
                                          sendEmail: false,
                                        );
                                        var emailOpened = false;
                                        if (sendEmail) {
                                          final selectedMembers = sendToAll
                                              ? provider.members
                                              : provider.members
                                                  .where((m) =>
                                                      selectedMemberIds
                                                          .contains(m.id))
                                                  .toList();
                                          final emails = selectedMembers
                                              .map((m) => m.email.trim())
                                              .where((e) => e.contains('@'))
                                              .toSet()
                                              .toList();
                                          if (emails.isEmpty) {
                                            if (mounted) {
                                              UiFeedback.showError(
                                                this.context,
                                                AppText.t(
                                                  this.context,
                                                  bn: 'কোনো valid email পাওয়া যায়নি',
                                                  en: 'No valid email found',
                                                ),
                                              );
                                            }
                                          } else {
                                            final primaryTo = emails.first;
                                            final bcc = emails.length > 1
                                                ? emails.sublist(1).join(',')
                                                : '';
                                            final uri = Uri(
                                              scheme: 'mailto',
                                              path: primaryTo,
                                              queryParameters: <String, String>{
                                                if (bcc.isNotEmpty) 'bcc': bcc,
                                                'subject': title,
                                                'body': text,
                                              },
                                            );
                                            final supported =
                                                await canLaunchUrl(uri);
                                            final opened = supported
                                                ? await launchUrl(
                                                    uri,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  )
                                                : false;
                                            emailOpened = opened;
                                            if (!opened && mounted) {
                                              UiFeedback.showError(
                                                this.context,
                                                AppText.t(
                                                  this.context,
                                                  bn: 'ইমেইল অ্যাপ খোলা যায়নি',
                                                  en: 'Could not open email app',
                                                ),
                                              );
                                            }
                                          }
                                        }
                                        if (!mounted) return;
                                        Navigator.pop(sheetContext);
                                        await _loadNotices();
                                        final msg = sendEmail && emailOpened
                                            ? AppText.t(
                                                this.context,
                                                bn: 'নোটিশ সেভ হয়েছে, ইমেইল অ্যাপ খোলা হয়েছে',
                                                en: 'Notice saved and email app opened',
                                              )
                                            : AppText.t(
                                                this.context,
                                                bn: 'নোটিশ যোগ হয়েছে',
                                                en: 'Notice added',
                                              );
                                        UiFeedback.showSuccess(this.context, msg);
                                      },
                                icon: saving
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check_rounded),
                                label: Text(AppText.t(context, bn: 'সেভ', en: 'Save')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateNoticeSheet,
        backgroundColor: const Color(0xFF2F5DFF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppText.t(context, bn: 'নোটিশ দিন', en: 'Add Notice')),
      ),
      appBar: AppBar(
        title: Text(AppText.t(context, bn: 'নোটিশ', en: 'Notice')),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF183153),
        actions: [
          IconButton(
            onPressed: _showCreateNoticeSheet,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          IconButton(
            onPressed: _loadNotices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notices.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFEAF0FF),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 32,
                            color: Color(0xFF2F5DFF),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppText.t(context,
                              bn: 'কোনো নোটিশ পাওয়া যায়নি',
                              en: 'No notice found'),
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF183153),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotices,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                    itemCount: _notices.length,
                    itemBuilder: (context, index) {
                      final notice = _notices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openDetails(notice),
                          child: Ink(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFDCE6FF)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF0FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.campaign_rounded,
                                    color: Color(0xFF2F5DFF),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notice.title,
                                        style: t.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF183153),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notice.text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.bodyMedium?.copyWith(
                                          color: const Color(0xFF4F5E78),
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F7FF),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              _formatDate(notice.date),
                                              style: t.labelSmall?.copyWith(
                                                color: const Color(0xFF2F5DFF),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFF99A7C2),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
