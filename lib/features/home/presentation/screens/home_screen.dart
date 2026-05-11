import 'package:flutter/material.dart';
import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:messmate_app_full/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:messmate_app_full/features/members/presentation/screens/members_screen.dart';
import 'package:messmate_app_full/features/notices/presentation/screens/notice_screen.dart';
import 'package:messmate_app_full/features/reports/presentation/screens/reports_screen.dart';
import 'package:messmate_app_full/features/utility/presentation/screens/utility_split_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final List<Widget?> _loadedScreens =
      List<Widget?>.filled(6, null, growable: false);

  Widget _buildScreen(int i) {
    switch (i) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const MembersScreen();
      case 2:
        return const ExpensesScreen();
      case 3:
        return const UtilitySplitScreen();
      case 4:
        return const ReportsScreen();
      case 5:
      default:
        return const NoticeScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadedScreens[0] = _buildScreen(0);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: index,
          children: List<Widget>.generate(
            _loadedScreens.length,
            (i) => _loadedScreens[i] ?? const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() {
            index = i;
            _loadedScreens[i] ??= _buildScreen(i);
          }),
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
              icon: const Icon(Icons.bolt_rounded),
              label: AppText.t(context, bn: 'ইউটিলিটি', en: 'Utility'),
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
