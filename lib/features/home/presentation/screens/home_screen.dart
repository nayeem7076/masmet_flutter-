import 'package:flutter/material.dart';
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
  final screens = const [
    DashboardScreen(),
    MembersScreen(),
    ExpensesScreen(),
    ReportsScreen(),
    NoticeScreen()
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.group), label: 'Members'),
            NavigationDestination(
                icon: Icon(Icons.shopping_bag), label: 'Bazar'),
            NavigationDestination(icon: Icon(Icons.receipt), label: 'Report'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'Notice'),
          ]));
}
