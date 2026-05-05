import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/expenses/data/models/expense.dart';

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
    final title = TextEditingController(text: e?.title ?? '');
    final amount =
        TextEditingController(text: e == null ? '' : e.amount.toString());
    final items = TextEditingController(text: e?.items.join(', ') ?? '');
    var cat = e?.category ?? 'bazar';
    var paidBy =
        e?.paidByMemberId ?? (p.members.isNotEmpty ? p.members.first.id : '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e == null ? 'Add Expense' : 'Edit Expense',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Expense title',
                    hintText: 'e.g. Bazar',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: items,
                  decoration: const InputDecoration(
                    labelText: 'Items (comma separated)',
                    hintText: 'e.g. rice, egg, oil',
                    prefixIcon: Icon(Icons.list_alt),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'e.g. 500',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: cat,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    'bazar',
                    'rent',
                    'gas',
                    'internet',
                    'bua',
                    'other'
                  ]
                      .map(
                        (x) => DropdownMenuItem(
                          value: x,
                          child: Text(
                            x[0].toUpperCase() + x.substring(1),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => cat = v ?? cat),
                ),
                const SizedBox(height: 12),
                if (p.members.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: paidBy,
                    decoration: const InputDecoration(
                      labelText: 'Paid by',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: p.members
                        .map((m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => paidBy = v ?? paidBy),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
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
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Save'),
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);
    final expenseList = p.expenses.reversed.toList();
    final totalExpense =
        expenseList.fold<double>(0, (sum, item) => sum + item.amount);
    final totalItems = expenseList.fold<int>(0, (sum, item) => sum + item.items.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar & Cost'),
        actions: [
          if (p.isManager)
            IconButton(
              onPressed: () {
                if (p.members.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Member নেই। আগে member add করুন, তারপর bazar/cost add করুন।',
                      ),
                    ),
                  );
                  return;
                }
                openForm(context, ref);
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total ৳${totalExpense.toStringAsFixed(0)} • ${expenseList.length} entries • $totalItems items',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (expenseList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long, size: 52, color: Color(0xFF90A4AE)),
                  const SizedBox(height: 10),
                  const Text(
                    'No Expenses Added Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap the + button to add your first bazar or cost entry.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  if (p.isManager) ...[
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () {
                        if (p.members.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Member নেই। আগে member add করুন, তারপর bazar/cost add করুন।',
                              ),
                            ),
                          );
                          return;
                        }
                        openForm(context, ref);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Expense'),
                    ),
                  ],
                ],
              ),
            )
          else
            ...expenseList.map((e) {
              final matches = p.members.where((m) => m.id == e.paidByMemberId);
              final paidBy = matches.isEmpty ? 'Unknown' : matches.first.name;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '৳${e.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          if (p.isManager)
                            PopupMenuButton<String>(
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                              onSelected: (v) async {
                                if (v == 'edit') openForm(context, ref, e);
                                if (v == 'delete') {
                                  final ok = await _confirmDelete(context);
                                  if (ok) await p.deleteExpense(e.id);
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip('Category: ${e.category}'),
                          _infoChip('Paid by: $paidBy'),
                        ],
                      ),
                      if (e.items.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          e.items.join(', '),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF0D47A1),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
