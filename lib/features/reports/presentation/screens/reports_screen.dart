import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/services/pdf_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _exportReport(BuildContext context, AppProvider p) async {
    try {
      final file = await PdfService.exportMonthlyReport(
        totalCost: p.totalCost,
        totalPaid: p.members.fold<double>(0, (sum, m) => sum + m.paidAmount),
        totalMembers: p.members.length,
        members: p.members
            .map(
              (m) => ReportMemberRow(
                name: m.name,
                paid: m.paidAmount,
                balance: p.memberBalance(m),
              ),
            )
            .toList(),
      );
      await PdfService.openFile(file);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved: ${file.path.split('/').last}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            onPressed: () => _exportReport(context, p),
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
                  Text(
                      'Total Paid: ৳${p.members.fold<double>(0, (s, m) => s + m.paidAmount).toStringAsFixed(0)}'),
                  Text('Total Members: ${p.members.length}'),
                  Text(
                    'Per Member Cost: ৳${p.equalCostPerMember.toStringAsFixed(0)}',
                  ),
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
            onPressed: () => _exportReport(context, p),
            icon: const Icon(Icons.print),
            label: const Text('Print / Export'),
          ),
        ],
      ),
    );
  }
}
