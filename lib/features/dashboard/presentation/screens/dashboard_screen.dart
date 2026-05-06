import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/screens/login_screen.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 44,
                      width: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.t(context,
                              bn: 'মেসমেট ড্যাশবোর্ড',
                              en: 'MessMate Dashboard'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppText.t(
                            context,
                            bn: 'মেম্বার, খরচ এবং ব্যালান্সের স্মার্ট নিয়ন্ত্রণ',
                            en: 'Smart control of members, cost and balance',
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
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
                ),
                _smartStatCard(
                  title: AppText.t(context, bn: 'মোট খরচ', en: 'Total Cost'),
                  value: '৳${provider.totalCost.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                ),
                _smartStatCard(
                  title: AppText.t(context, bn: 'মোট জমা', en: 'Total Paid'),
                  value: '৳${totalPaid.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _smartStatCard(
                  title: AppText.t(context, bn: 'খরচ এন্ট্রি', en: 'Expenses'),
                  value: '${provider.expenses.length}',
                  icon: Icons.receipt_long_outlined,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
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
