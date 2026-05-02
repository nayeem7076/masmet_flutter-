import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'members_screen.dart';
import 'expenses_screen.dart';
import 'reports_screen.dart';
import 'notice_screen.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> { int index = 0; final screens = const [DashboardScreen(), MembersScreen(), ExpensesScreen(), ReportsScreen(), NoticeScreen()];
  @override Widget build(BuildContext context) => Scaffold(body: screens[index], bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), destinations: const [
    NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'), NavigationDestination(icon: Icon(Icons.group), label: 'Members'), NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'Bazar'), NavigationDestination(icon: Icon(Icons.receipt), label: 'Report'), NavigationDestination(icon: Icon(Icons.chat), label: 'Notice'),
  ]));
}
