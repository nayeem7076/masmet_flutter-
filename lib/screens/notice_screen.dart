import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notice.dart';
import '../providers/app_provider.dart';

class NoticeScreen extends ConsumerWidget {
  const NoticeScreen({super.key});

  void openNoticeDialog(BuildContext context, WidgetRef ref,
      {NoticeItem? notice}) {
    final provider = ref.read(appProviderProvider);
    final titleController = TextEditingController(text: notice?.title ?? '');
    final messageController = TextEditingController(text: notice?.text ?? '');
    var sendToAll = notice?.sendToAll ?? true;
    final selectedMemberIds = <String>{...(notice?.targetMemberIds ?? [])};

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(notice == null ? 'Add Notice' : 'Edit Notice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Notice Title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Notice Message',
                        prefixIcon: Icon(Icons.message_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Send to all members'),
                      value: sendToAll,
                      onChanged: (value) {
                        setState(() {
                          sendToAll = value;
                          if (sendToAll) selectedMemberIds.clear();
                        });
                      },
                    ),
                    if (!sendToAll)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          const Text(
                            'Select members',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          ...provider.members.map((member) {
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: selectedMemberIds.contains(member.id),
                              title: Text(member.name),
                              subtitle: Text(member.phone),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedMemberIds.add(member.id);
                                  } else {
                                    selectedMemberIds.remove(member.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final message = messageController.text.trim();

                    if (title.isEmpty || message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please write title and message')),
                      );
                      return;
                    }

                    if (!sendToAll && selectedMemberIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select at least one member')),
                      );
                      return;
                    }

                    if (notice == null) {
                      final emailSent = await provider.addNotice(
                        title: title,
                        text: message,
                        sendToAll: sendToAll,
                        targetMemberIds: selectedMemberIds.toList(),
                        sendEmail: true,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              emailSent
                                  ? 'Notice added and email sent'
                                  : 'Notice added. Email not sent. Check backend/server and member email.',
                            ),
                          ),
                        );
                      }
                    } else {
                      await provider.updateNotice(
                        notice: notice,
                        title: title,
                        text: message,
                        sendToAll: sendToAll,
                        targetMemberIds: selectedMemberIds.toList(),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notice updated')),
                        );
                      }
                    }

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: Text(notice == null ? 'Send Notice' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appProviderProvider);
    final notices = provider.visibleNoticesForCurrentUser().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice'),
        actions: [
          if (provider.isManager)
            IconButton(
              onPressed: () => openNoticeDialog(context, ref),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: notices.isEmpty
          ? const Center(
              child: Text(
                'No notice found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                final targetText = notice.sendToAll
                    ? 'All members'
                    : '${notice.targetMemberIds.length} selected member(s)';

                return Card(
                  elevation: 3,
                  shadowColor: Colors.black12,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE3F2FD),
                              child: Icon(
                                Icons.campaign,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notice.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${notice.sender} • $targetText',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (provider.isManager)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    openNoticeDialog(context, ref,
                                        notice: notice);
                                  } else if (value == 'delete') {
                                    provider.deleteNotice(notice.id);
                                  }
                                },
                                itemBuilder: (context) {
                                  return const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ];
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notice.text,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${notice.date.day}/${notice.date.month}/${notice.date.year} ${notice.date.hour}:${notice.date.minute.toString().padLeft(2, '0')}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: provider.isManager
          ? FloatingActionButton.extended(
              onPressed: () => openNoticeDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Notice'),
            )
          : null,
    );
  }
}
