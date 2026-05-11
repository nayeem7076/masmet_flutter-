import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/screens/login_screen.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final provider = ref.watch(appProviderProvider);
    final totalPaid = provider.members
        .fold<double>(0, (sum, member) => sum + member.paidAmount);
    final totalDue = provider.members.fold<double>(
      0,
      (sum, member) =>
          sum +
          (provider.memberBalance(member) < 0
              ? provider.memberBalance(member).abs()
              : 0),
    );
    final totalAdvance = provider.members.fold<double>(
      0,
      (sum, member) =>
          sum +
          (provider.memberBalance(member) > 0
              ? provider.memberBalance(member)
              : 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(AppText.t(context, bn: 'ড্যাশবোর্ড', en: 'Dashboard')),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) async {
              if (value == 'bn' || value == 'en') {
                await provider.setLanguageCode(value);
                return;
              }
              if (value == 'logout') {
                await provider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'bn',
                child: Text(
                  provider.languageCode == 'bn'
                      ? '✓ বাংলা'
                      : AppText.t(context, bn: 'বাংলা', en: 'Bangla'),
                ),
              ),
              PopupMenuItem(
                value: 'en',
                child: Text(
                  provider.languageCode == 'en' ? '✓ English' : 'English',
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text(AppText.t(context, bn: 'লগআউট', en: 'Logout')),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3290FF), Color(0xFF0D4CB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33114284),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -34,
                    right: -22,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0x26FFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: -18,
                    child: Container(
                      width: 94,
                      height: 94,
                      decoration: const BoxDecoration(
                        color: Color(0x1FFFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0x24FFFFFF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x66FFFFFF)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1AFFFFFF),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.t(context,
                                  bn: 'মেসমেট ড্যাশবোর্ড',
                                  en: 'MessMate\nDashboard'),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.25,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppText.t(
                                context,
                                bn: 'মেম্বার, খরচ এবং ব্যালান্সের স্মার্ট নিয়ন্ত্রণ',
                                en: 'Smart control of members, cost and balance',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xD9E7F7FF),
                                height: 1.2,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _LiveClockChip(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.22,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: [
                _smartStatCard(
                  title: AppText.t(context, bn: 'মেম্বার', en: 'Members'),
                  value: '${provider.members.length}',
                  icon: Icons.groups_rounded,
                  onTap: () => _showMembersSheet(context, provider),
                ),
                _smartStatCard(
                  title: AppText.t(context, bn: 'মোট খরচ', en: 'Total Cost'),
                  value: '৳${provider.totalCost.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                  onTap: () => _showTotalCostSheet(context, provider),
                ),
                _smartStatCard(
                  title: AppText.t(context, bn: 'মোট জমা', en: 'Total Paid'),
                  value: '৳${totalPaid.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => _showTotalPaidSheet(context, provider),
                ),
                _smartStatCard(
                  title: AppText.t(context, bn: 'খরচ এন্ট্রি', en: 'Expenses'),
                  value: '${provider.expenses.length}',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => _showExpenseCountSheet(context, provider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.t(context,
                          bn: 'আর্থিক সারাংশ', en: 'Financial Insights'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _insightRow(
                      AppText.t(context, bn: 'রোল', en: 'Role'),
                      provider.currentRole.toUpperCase(),
                    ),
                    _insightRow(
                      AppText.t(context,
                          bn: 'প্রতি মেম্বার খরচ', en: 'Per Member Cost'),
                      '৳${provider.equalCostPerMember.toStringAsFixed(0)}',
                    ),
                    _insightRow(
                      AppText.t(context, bn: 'মোট অগ্রিম', en: 'Total Advance'),
                      '৳${totalAdvance.toStringAsFixed(0)}',
                    ),
                    _insightRow(
                      AppText.t(context, bn: 'মোট বকেয়া', en: 'Total Due'),
                      '৳${totalDue.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smartStatCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1565C0), size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  void _showMembersSheet(BuildContext context, AppProvider provider) {
    _showSimpleListSheet(
      context: context,
      title: AppText.t(context, bn: 'মেম্বার লিস্ট', en: 'Member List'),
      emptyText: AppText.t(
        context,
        bn: 'এখনও কোনো মেম্বার যোগ করা হয়নি।',
        en: 'No members added yet.',
      ),
      rows: provider.members
          .map(
            (m) => _DetailRow(
              title: m.name,
              subtitle: m.phone.trim().isEmpty ? null : m.phone,
              actionLabel: m.phone.trim().isEmpty
                  ? null
                  : AppText.t(context, bn: 'কল', en: 'Call'),
              onActionTap:
                  m.phone.trim().isEmpty ? null : () => _openDialer(m.phone),
            ),
          )
          .toList(),
    );
  }

  void _showTotalCostSheet(BuildContext context, AppProvider provider) {
    final memberNames = <String, String>{
      for (final member in provider.members) member.id: member.name,
    };
    final costByMember = <String, double>{};
    final expenseTitlesByMember = <String, List<String>>{};
    for (final expense in provider.expenses) {
      final id = expense.paidByMemberId;
      costByMember[id] = (costByMember[id] ?? 0) + expense.amount;
      expenseTitlesByMember
          .putIfAbsent(id, () => <String>[])
          .add(expense.title);
    }
    final rows = costByMember.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _showSimpleListSheet(
      context: context,
      title: AppText.t(context, bn: 'কার মাধ্যমে কত খরচ', en: 'Cost By Member'),
      emptyText: AppText.t(
        context,
        bn: 'এখনও কোনো খরচ যোগ করা হয়নি।',
        en: 'No costs added yet.',
      ),
      rows: rows.map(
        (e) {
          final expenseTitles =
              (expenseTitlesByMember[e.key] ?? const <String>[]);
          final preview = expenseTitles.take(3).join(', ');
          return _DetailRow(
            title: memberNames[e.key] ??
                AppText.t(context, bn: 'অজানা', en: 'Unknown'),
            subtitle: preview.isEmpty ? null : preview,
            value: '৳${e.value.toStringAsFixed(0)}',
          );
        },
      ).toList(),
    );
  }

  void _showTotalPaidSheet(BuildContext context, AppProvider provider) {
    final rows = provider.members.toList()
      ..sort((a, b) => b.paidAmount.compareTo(a.paidAmount));
    _showSimpleListSheet(
      context: context,
      title:
          AppText.t(context, bn: 'কে কত টাকা জমা দিয়েছে', en: 'Paid By Member'),
      emptyText: AppText.t(
        context,
        bn: 'এখনও কোনো মেম্বার নেই।',
        en: 'No members found.',
      ),
      rows: rows
          .map(
            (m) => _DetailRow(
              title: m.name,
              subtitle: m.phone,
              value: '৳${m.paidAmount.toStringAsFixed(0)}',
            ),
          )
          .toList(),
    );
  }

  void _showExpenseCountSheet(BuildContext context, AppProvider provider) {
    final memberNames = <String, String>{
      for (final member in provider.members) member.id: member.name,
    };
    final countByMember = <String, int>{};
    for (final expense in provider.expenses) {
      final id = expense.paidByMemberId;
      countByMember[id] = (countByMember[id] ?? 0) + 1;
    }
    final rows = countByMember.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _showSimpleListSheet(
      context: context,
      title: AppText.t(
        context,
        bn: 'কে কয়টা খরচ এন্ট্রি করেছে',
        en: 'Expense Entries By Member',
      ),
      emptyText: AppText.t(
        context,
        bn: 'এখনও কোনো খরচ এন্ট্রি নেই।',
        en: 'No expense entries yet.',
      ),
      rows: rows
          .map(
            (e) => _DetailRow(
              title: memberNames[e.key] ??
                  AppText.t(context, bn: 'অজানা', en: 'Unknown'),
              value: '${e.value}',
            ),
          )
          .toList(),
    );
  }

  void _showSimpleListSheet({
    required BuildContext context,
    required String title,
    required String emptyText,
    required List<_DetailRow> rows,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8C1CC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEAF3FF), Color(0xFFF5F9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCEBFF)),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: Color(0xFF123F79),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (rows.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF6B7A90),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              emptyText,
                              style: const TextStyle(
                                color: Color(0xFF5F6B7C),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (rows.isNotEmpty)
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final row = rows[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFE),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE7EEFA)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        row.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (row.subtitle != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          row.subtitle!,
                                          style: const TextStyle(
                                            color: Color(0xFF667085),
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (row.value != null)
                                  Text(
                                    row.value!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                if (row.actionLabel != null)
                                  TextButton(
                                    onPressed: row.onActionTap,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.call_rounded,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(row.actionLabel!),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(label, style: const TextStyle(color: Colors.black54))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String title;
  final String? subtitle;
  final String? value;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _DetailRow({
    required this.title,
    this.subtitle,
    this.value,
    this.actionLabel,
    this.onActionTap,
  });
}

class _LiveClockChip extends StatefulWidget {
  const _LiveClockChip();

  @override
  State<_LiveClockChip> createState() => _LiveClockChipState();
}

class _LiveClockChipState extends State<_LiveClockChip> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x30FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x77FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${DateFormat('dd MMM yyyy').format(_now)}  •  ${DateFormat('hh:mm:ss a').format(_now)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
