import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final provider = ref.read(appProviderProvider);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => !provider.onboarded
              ? const OnboardingScreen()
              : provider.isLoggedIn
                  ? const HomeScreen()
                  : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
              'MessMate',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Smart Mess Management',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
