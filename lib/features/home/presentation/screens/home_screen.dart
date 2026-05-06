import 'package:flutter/material.dart';
import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:messmate_app_full/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:messmate_app_full/features/members/presentation/screens/members_screen.dart';
import 'package:messmate_app_full/features/notices/presentation/screens/notice_screen.dart';
import 'package:messmate_app_full/features/reports/presentation/screens/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final List<Widget> screens = const [
    DashboardScreen(),
    MembersScreen(),
    ExpensesScreen(),
    ReportsScreen(),
    NoticeScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: index,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard),
              label: AppText.tr(context, AppText.home),
            ),
            NavigationDestination(
              icon: const Icon(Icons.group),
              label: AppText.tr(context, AppText.members),
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag),
              label: AppText.tr(context, AppText.bazar),
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt),
              label: AppText.tr(context, AppText.report),
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat),
              label: AppText.tr(context, AppText.notice),
            ),
          ],
        ),
      );
}
