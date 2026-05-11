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
  late final PageController _pageController;
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
    _pageController = PageController(initialPage: index);
    _loadedScreens[0] = _buildScreen(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => index = i),
          itemCount: _loadedScreens.length,
          itemBuilder: (context, i) {
            _loadedScreens[i] ??= _buildScreen(i);
            return KeyedSubtree(
              key: PageStorageKey<String>('home_tab_$i'),
              child: _loadedScreens[i]!,
            );
          },
        ),
        bottomNavigationBar: NavigationBar(
          animationDuration: const Duration(milliseconds: 520),
          height: 72,
          indicatorColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
          selectedIndex: index,
          onDestinationSelected: (i) {
            if (i == index) return;
            setState(() {
              index = i;
            });
            _loadedScreens[i] ??= _buildScreen(i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
            );
          },
          destinations: [
            NavigationDestination(
              icon: _AnimatedNavIcon(
                icon: Icons.dashboard_rounded,
                active: index == 0,
              ),
              selectedIcon: const Icon(Icons.dashboard_customize_rounded),
              label: AppText.tr(context, AppText.home),
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                icon: Icons.group_rounded,
                active: index == 1,
              ),
              selectedIcon: const Icon(Icons.groups_rounded),
              label: AppText.tr(context, AppText.members),
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                icon: Icons.shopping_bag_rounded,
                active: index == 2,
              ),
              selectedIcon: const Icon(Icons.shopping_bag),
              label: AppText.tr(context, AppText.bazar),
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                icon: Icons.bolt_rounded,
                active: index == 3,
              ),
              selectedIcon: const Icon(Icons.electric_bolt_rounded),
              label: AppText.t(context, bn: 'ইউটিলিটি', en: 'Utility'),
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                icon: Icons.receipt_long_rounded,
                active: index == 4,
              ),
              selectedIcon: const Icon(Icons.receipt_rounded),
              label: AppText.tr(context, AppText.report),
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                icon: Icons.chat_bubble_rounded,
                active: index == 5,
              ),
              selectedIcon: const Icon(Icons.chat_rounded),
              label: AppText.tr(context, AppText.notice),
            ),
          ],
        ),
      );
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _AnimatedNavIcon({
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      offset: active ? const Offset(0, -0.12) : Offset.zero,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: active ? 1 : 0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder: (context, t, child) {
          return Transform.scale(
            scale: 1 + (0.16 * t),
            child: Transform.rotate(
              angle: (1 - t) * 0.08,
              child: Opacity(
                opacity: 0.78 + (0.22 * t),
                child: child,
              ),
            ),
          );
        },
        child: Icon(icon),
      ),
    );
  }
}
