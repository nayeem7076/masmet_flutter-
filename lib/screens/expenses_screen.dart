import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../providers/app_provider.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
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

  void openForm(BuildContext context, WidgetRef ref, [Expense? e]) {
    final p = ref.read(appProviderProvider);
    final title = TextEditingController(text: e?.title ?? 'Bazar');
    final amount = TextEditingController(text: (e?.amount ?? 0).toString());
    final items =
        TextEditingController(text: e?.items.join(', ') ?? 'rice, egg, oil');
    var cat = e?.category ?? 'bazar';
    var paidBy =
        e?.paidByMemberId ?? (p.members.isNotEmpty ? p.members.first.id : '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(e == null ? 'Add Bazar/Cost' : 'Edit Bazar/Cost'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: items,
                  decoration: const InputDecoration(
                    labelText: 'What did you buy? comma separated',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: cat,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    'bazar',
                    'rent',
                    'gas',
                    'internet',
                    'bua',
                    'other'
                  ]
                      .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                      .toList(),
                  onChanged: (v) => setState(() => cat = v!),
                ),
                const SizedBox(height: 10),
                if (p.members.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: paidBy,
                    decoration: const InputDecoration(labelText: 'Paid By'),
                    items: p.members
                        .map((m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => paidBy = v!),
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
                final list = items.text
                    .split(',')
                    .map((x) => x.trim())
                    .where((x) => x.isNotEmpty)
                    .toList();
                try {
                  if (e == null) {
                    await p.addExpense(
                      title.text,
                      double.tryParse(amount.text) ?? 0,
                      paidBy,
                      cat,
                      list,
                    );
                  } else {
                    await p.updateExpense(
                      e,
                      title.text,
                      double.tryParse(amount.text) ?? 0,
                      cat,
                      list,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (err) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        err.toString().replaceFirst('Exception: ', ''),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar & Cost'),
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
        itemCount: p.expenses.length,
        itemBuilder: (_, i) {
          final e = p.expenses.reversed.toList()[i];
          final matches = p.members.where((m) => m.id == e.paidByMemberId);
          final paidBy = matches.isEmpty ? 'Unknown' : matches.first.name;
          return Card(
            child: ListTile(
              title: Text('${e.title} - ৳${e.amount.toStringAsFixed(0)}'),
              subtitle: Text(
                'Items: ${e.items.join(', ')}\nCategory: ${e.category} | Paid by: $paidBy',
              ),
              isThreeLine: true,
              trailing: p.isManager
                  ? PopupMenuButton<String>(
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (v) async {
                        if (v == 'edit') openForm(context, ref, e);
                        if (v == 'delete') {
                          final ok = await _confirmDelete(context);
                          if (ok) {
                            await p.deleteExpense(e.id);
                          }
                        }
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
