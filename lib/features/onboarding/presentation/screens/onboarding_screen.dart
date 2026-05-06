import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/screens/login_screen.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 170,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                AppText.t(
                  context,
                  bn: 'সহজে আপনার মেস পরিচালনা করুন',
                  en: 'Manage your mess easily',
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
                  bn: 'মেম্বার, বাজার তালিকা, মিল কাউন্ট, অগ্রিম পেমেন্ট, বকেয়া হিসাব এবং মাসিক রিপোর্ট - সব এক অ্যাপে।',
                  en: 'Member, bazar list, meal count, advance payment, due calculation and monthly report in one app.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () async {
                  await ref.read(appProviderProvider).finishOnboarding();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Text(
                    AppText.t(context, bn: 'শুরু করুন', en: 'Get Started')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
