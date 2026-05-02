import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';
import '../providers/app_provider.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  void openForm(BuildContext context, WidgetRef ref, [Member? m]) {
    final name = TextEditingController(text: m?.name ?? '');
    final phone = TextEditingController(text: m?.phone ?? '');
    final paid = TextEditingController(text: (m?.paidAmount ?? 0).toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(m == null ? 'Add Member' : 'Edit Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Member Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: paid,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Advance/Paid Amount',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final p = ref.read(appProviderProvider);
              if (m == null) {
                await p.addMember(
                  name.text,
                  phone.text,
                  double.tryParse(paid.text) ?? 0,
                );
              } else {
                await p.updateMember(
                  m,
                  name.text,
                  phone.text,
                  double.tryParse(paid.text) ?? 0,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          if (p.isManager)
            IconButton(
              onPressed: () => openForm(context, ref),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: p.members.length,
        itemBuilder: (_, i) {
          final m = p.members[i];
          final bal = p.memberBalance(m);

          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(m.name),
              subtitle: Text(
                '${m.phone}\nPaid: ৳${m.paidAmount.toStringAsFixed(0)}',
              ),
              isThreeLine: false,
              trailing: p.isManager
                  ? PopupMenuButton<String>(
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'pay', child: Text('Add Payment')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (v) {
                        if (v == 'edit') openForm(context, ref, m);
                        if (v == 'delete') p.deleteMember(m.id);
                        if (v == 'pay') {
                          final c = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Add Payment'),
                              content: TextField(
                                controller: c,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Amount'),
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    p.addPayment(
                                        m, double.tryParse(c.text) ?? 0);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    )
                  : Text(
                      bal >= 0
                          ? 'Advance\n৳${bal.toStringAsFixed(0)}'
                          : 'Due\n৳${bal.abs().toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: bal >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
