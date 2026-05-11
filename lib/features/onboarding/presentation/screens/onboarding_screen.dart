import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/home/presentation/screens/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _index = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      imagePath: 'assets/images/onboding1.jpeg',
      bnTitle: 'সহজে আপনার মেস পরিচালনা করুন',
      enTitle: 'Manage your mess easily',
      bnSubtitle: 'সবকিছু এক জায়গা থেকে কন্ট্রোল করুন।',
      enSubtitle: 'Control everything from one place.',
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboding2.jpeg',
      bnTitle: 'মেম্বার ও মিল ট্র্যাক করুন',
      enTitle: 'Track members and meals',
      bnSubtitle: 'মেম্বার, মিল এবং খরচের হিসাব দ্রুত দেখুন।',
      enSubtitle: 'Track members, meals, and costs quickly.',
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboding3.jpeg',
      bnTitle: 'খরচ ও বকেয়া হিসাব করুন',
      enTitle: 'Calculate cost and dues',
      bnSubtitle: 'কে কত দিলো বা পাবে, সব অটোমেটিক হিসাব।',
      enSubtitle: 'Auto-calculate who paid and who should receive.',
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboding4.jpeg',
      bnTitle: 'রিপোর্ট ও শেয়ার সহজ করুন',
      enTitle: 'Make reports and sharing easy',
      bnSubtitle: 'রিপোর্ট দেখে দ্রুত সিদ্ধান্ত নিন।',
      enSubtitle: 'View reports and decide faster.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(appProviderProvider).finishOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _items.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            item.imagePath,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          AppText.t(
                            context,
                            bn: item.bnTitle,
                            en: item.enTitle,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppText.t(
                            context,
                            bn: item.bnSubtitle,
                            en: item.enSubtitle,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black54),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? const Color(0xFF1565C0)
                          : const Color(0xFFD0D8E6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (isLast) {
                      await _completeOnboarding();
                      return;
                    }
                    await _pageController.nextPage(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Text(
                    isLast
                        ? AppText.t(context, bn: 'শুরু করুন', en: 'Get Started')
                        : AppText.t(context, bn: 'পরবর্তী', en: 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String imagePath;
  final String bnTitle;
  final String enTitle;
  final String bnSubtitle;
  final String enSubtitle;

  const _OnboardingItem({
    required this.imagePath,
    required this.bnTitle,
    required this.enTitle,
    required this.bnSubtitle,
    required this.enSubtitle,
  });
}
