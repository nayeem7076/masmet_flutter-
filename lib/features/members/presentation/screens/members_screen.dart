import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/members/data/models/member.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Member'),
        content: const Text('Are you sure you want to delete this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void openForm(BuildContext context, WidgetRef ref, [Member? m]) {
    final name = TextEditingController(text: m?.name ?? '');
    final email = TextEditingController(text: m?.email ?? '');
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
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Member Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phone,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: paid,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Advance/Paid Amount',
                  prefixIcon: Icon(Icons.payments_outlined),
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
              try {
                if (m == null) {
                  await p.addMember(
                    name.text,
                    email.text,
                    phone.text,
                    double.tryParse(paid.text) ?? 0,
                  );
                } else {
                  await p.updateMember(
                    m,
                    name.text,
                    email.text,
                    phone.text,
                    double.tryParse(paid.text) ?? 0,
                  );
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString().replaceFirst('Exception: ', ''),
                    ),
                  ),
                );
              }
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
                '${m.email}\n${m.phone}\nPaid: ৳${m.paidAmount.toStringAsFixed(0)}',
              ),
              isThreeLine: true,
              trailing: p.isManager
                  ? PopupMenuButton<String>(
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'pay', child: Text('Add Payment')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (v) async {
                        if (v == 'edit') openForm(context, ref, m);
                        if (v == 'delete') {
                          final ok = await _confirmDelete(context);
                          if (ok) {
                            await p.deleteMember(m.id);
                          }
                        }
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
                                  onPressed: () async {
                                    try {
                                      await p.addPayment(
                                        m,
                                        double.tryParse(c.text) ?? 0,
                                      );
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceFirst(
                                                  'Exception: ',
                                                  '',
                                                ),
                                          ),
                                        ),
                                      );
                                    }
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
