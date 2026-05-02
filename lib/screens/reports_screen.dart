import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF/Excel export mock ready')),
            ),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Cost: ৳${p.totalCost.toStringAsFixed(0)}'),
                  Text('Total Paid: ৳${p.members.fold<double>(0, (s, m) => s + m.paidAmount).toStringAsFixed(0)}'),
                  Text('Total Members: ${p.members.length}'),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Balance')),
              ],
              rows: p.members.map((m) {
                final bal = p.memberBalance(m);
                return DataRow(
                  cells: [
                    DataCell(Text(m.name)),
                    DataCell(Text('৳${m.paidAmount.toStringAsFixed(0)}')),
                    DataCell(
                      Text(
                        bal >= 0
                            ? 'Advance ৳${bal.toStringAsFixed(0)}'
                            : 'Due ৳${bal.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          color: bal >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Print/PDF/Excel placeholder ready')),
            ),
            icon: const Icon(Icons.print),
            label: const Text('Print / Export'),
          ),
        ],
      ),
    );
  }
}
