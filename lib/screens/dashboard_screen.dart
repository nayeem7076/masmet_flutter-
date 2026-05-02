import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import 'login_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appProviderProvider);

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
            const Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MessMate',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Smart Mess Management',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                AppCard(
                  title: 'Members',
                  value: '${provider.members.length}',
                  icon: Icons.groups,
                ),
                AppCard(
                  title: 'Total Cost',
                  value: '৳${provider.totalCost.toStringAsFixed(0)}',
                  icon: Icons.payments,
                ),
                AppCard(
                  title: 'Total Paid',
                  value: '৳${provider.members.fold<double>(0, (s, m) => s + m.paidAmount).toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet,
                ),
                AppCard(
                  title: 'Expenses',
                  value: '${provider.expenses.length}',
                  icon: Icons.receipt_long,
                ),
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Summary',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('Logged in as: ${provider.currentRole.toUpperCase()}'),
                    const Text('Manager can add/edit/delete all data'),
                    const Text('Member can see cost and report'),
                    const Text('Forgot password uses mock OTP: 1234'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
