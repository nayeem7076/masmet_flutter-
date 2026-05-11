import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/core/ui/ui_feedback.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/services/pdf_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  void _showSummaryDetails(
    BuildContext context, {
    required String title,
    required List<_SettlementRow> rows,
    required Color color,
    required String emptyText,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                if (rows.isEmpty) Text(emptyText),
                if (rows.isNotEmpty)
                  ...rows.map(
                    (row) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              row.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            'Tk ${row.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportReport(BuildContext context, AppProvider p) async {
    try {
      final receivers = p.receivableSettlements;
      final payers = p.payableSettlements;
      final result = await PdfService.exportMonthlyReport(
        totalCost: p.totalCost,
        totalPaid: p.members.fold<double>(0, (sum, m) => sum + m.paidAmount),
        totalMembers: p.members.length,
        totalReceivable: receivers.fold<double>(
          0,
          (sum, settlement) => sum + settlement.netAmount,
        ),
        totalPayable: payers.fold<double>(
          0,
          (sum, settlement) => sum + settlement.netAmount.abs(),
        ),
        gasBill: p.gasBill,
        currentBill: p.currentBill,
        members: p.memberSettlements
            .map(
              (settlement) => ReportMemberRow(
                name: settlement.member.name,
                paid: settlement.paid,
                share: settlement.share,
                balance: settlement.netAmount,
              ),
            )
            .toList(),
      ).timeout(const Duration(seconds: 15));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? AppText.t(context,
                    bn: 'PDF ডাউনলোড হয়েছে: $result',
                    en: 'PDF downloaded: $result')
                : AppText.t(
                    context,
                    bn: 'PDF সেভ এবং ওপেন হয়েছে: ${result.split('/').last}',
                    en: 'PDF saved and opened: ${result.split('/').last}',
                  ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppText.t(context,
                bn: 'এক্সপোর্ট ব্যর্থ: ${e.toString()}',
                en: 'Export failed: ${e.toString()}'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);
    final settlements = p.memberSettlements;
    final receivers = p.receivableSettlements;
    final payers = p.payableSettlements;
    final totalPaid =
        p.members.fold<double>(0, (sum, member) => sum + member.paidAmount);
    final totalReceivable = receivers.fold<double>(
      0,
      (sum, settlement) => sum + settlement.netAmount,
    );
    final totalPayable = payers.fold<double>(
      0,
      (sum, settlement) => sum + settlement.netAmount.abs(),
    );
    final receiverRows = receivers
        .map(
          (settlement) => _SettlementRow(
            name: settlement.member.name,
            amount: settlement.netAmount,
            isReceive: true,
          ),
        )
        .toList();
    final payerRows = payers
        .map(
          (settlement) => _SettlementRow(
            name: settlement.member.name,
            amount: settlement.netAmount.abs(),
            isReceive: false,
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppText.t(context, bn: 'মাসিক রিপোর্ট', en: 'Monthly Report')),
        actions: [
          IconButton(
            onPressed: () => AppLoader.run<void>(
              context: context,
              message: AppText.t(context,
                  bn: 'রিপোর্ট প্রস্তুত হচ্ছে...', en: 'Preparing report...'),
              task: () => _exportReport(context, p),
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
                  Text(
                    AppText.t(context,
                        bn: 'রিপোর্ট সারসংক্ষেপ', en: 'Report Summary'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SummaryBox(
                        label:
                            AppText.t(context, bn: 'মোট জমা', en: 'Total Paid'),
                        value: 'Tk ${totalPaid.toStringAsFixed(0)}',
                      ),
                      _SummaryBox(
                        label: AppText.t(context,
                            bn: 'মোট খরচ', en: 'Total Expense'),
                        value: 'Tk ${p.totalCost.toStringAsFixed(0)}',
                      ),
                      _SummaryBox(
                        label: AppText.t(context,
                            bn: 'মোট মেম্বার', en: 'Total Members'),
                        value: '${p.members.length}',
                      ),
                      _SummaryBox(
                        label: AppText.t(context,
                            bn: 'প্রতি মেম্বার শেয়ার', en: 'Per Member Share'),
                        value: 'Tk ${p.equalCostPerMember.toStringAsFixed(0)}',
                      ),
                      _SummaryBox(
                        label: AppText.t(context,
                            bn: 'মোট পাওনা', en: 'Total Receivable'),
                        value: 'Tk ${totalReceivable.toStringAsFixed(0)}',
                        accentColor: Theme.of(context).colorScheme.primary,
                        onTap: () => _showSummaryDetails(
                          context,
                          title: AppText.t(context,
                              bn: 'যারা টাকা পাবে',
                              en: 'Members Who Will Receive'),
                          rows: receiverRows,
                          color: Theme.of(context).colorScheme.primary,
                          emptyText: AppText.t(context,
                              bn: 'কেউ টাকা পাবে না।',
                              en: 'No member will receive money.'),
                        ),
                      ),
                      _SummaryBox(
                        label: AppText.t(context,
                            bn: 'মোট বকেয়া', en: 'Total Payable'),
                        value: 'Tk ${totalPayable.toStringAsFixed(0)}',
                        accentColor: Colors.red,
                        onTap: () => _showSummaryDetails(
                          context,
                          title: AppText.t(context,
                              bn: 'যাদের টাকা দিতে হবে',
                              en: 'Members Who Need To Pay'),
                          rows: payerRows,
                          color: Colors.red,
                          emptyText: AppText.t(context,
                              bn: 'কোনো বকেয়া নেই।',
                              en: 'No pending payment remaining.'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Text(AppText.t(context, bn: 'নাম', en: 'Name')),
                ),
                DataColumn(
                  label: Text(AppText.t(context, bn: 'জমা', en: 'Paid')),
                ),
                DataColumn(
                  label: Text(AppText.t(context, bn: 'শেয়ার', en: 'Share')),
                ),
                DataColumn(
                  label: Text(AppText.t(context, bn: 'অবস্থা', en: 'Status')),
                ),
              ],
              rows: settlements.map((settlement) {
                final balance = settlement.netAmount;
                final isReceive = balance >= 0;
                return DataRow(
                  cells: [
                    DataCell(Text(settlement.member.name)),
                    DataCell(Text('Tk ${settlement.paid.toStringAsFixed(0)}')),
                    DataCell(
                      Text('Tk ${settlement.share.toStringAsFixed(0)}'),
                    ),
                    DataCell(
                      Text(
                        isReceive
                            ? AppText.t(context,
                                bn: 'পাবে Tk ${balance.toStringAsFixed(0)}',
                                en: 'Receive Tk ${balance.toStringAsFixed(0)}')
                            : AppText.t(context,
                                bn: 'দেবে Tk ${balance.abs().toStringAsFixed(0)}',
                                en: 'Pay Tk ${balance.abs().toStringAsFixed(0)}'),
                        style: TextStyle(
                          color: isReceive ? Colors.green : Colors.red,
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
          _SettlementSection(
            title: AppText.t(context,
                bn: 'যারা টাকা পাবে', en: 'Members Who Will Receive'),
            emptyText: AppText.t(context,
                bn: 'কেউ অতিরিক্ত দেয়নি।', en: 'No one paid extra.'),
            rows: receiverRows,
          ),
          const SizedBox(height: 12),
          _SettlementSection(
            title: AppText.t(context,
                bn: 'যাদের টাকা দিতে হবে', en: 'Members Who Need To Pay'),
            emptyText: AppText.t(context,
                bn: 'কোনো বকেয়া নেই।', en: 'No dues remaining.'),
            rows: payerRows,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => AppLoader.run<void>(
              context: context,
              message: AppText.t(context,
                  bn: 'রিপোর্ট এক্সপোর্ট হচ্ছে...', en: 'Exporting report...'),
              task: () => _exportReport(context, p),
            ),
            icon: const Icon(Icons.print),
            label: Text(AppText.t(context,
                bn: 'প্রিন্ট / এক্সপোর্ট', en: 'Print / Export')),
          ),
        ],
      ),
    );
  }
}

class _SettlementSection extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<_SettlementRow> rows;

  const _SettlementSection({
    required this.title,
    required this.emptyText,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final boxColor =
        rows.isNotEmpty && rows.first.isReceive ? primaryColor : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty) Text(emptyText),
            if (rows.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: rows
                    .map(
                      (row) => Container(
                        width: 145,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: boxColor.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              row.isReceive ? 'Pabe' : 'Dibe',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tk ${row.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettlementRow {
  final String name;
  final double amount;
  final bool isReceive;

  const _SettlementRow({
    required this.name,
    required this.amount,
    required this.isReceive,
  });
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;
  final VoidCallback? onTap;

  const _SummaryBox({
    required this.label,
    required this.value,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
