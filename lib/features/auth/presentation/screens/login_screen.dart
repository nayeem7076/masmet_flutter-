import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/core/ui/ui_feedback.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/home/presentation/screens/home_screen.dart';

import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'manager';
  bool isSubmitting = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      UiFeedback.showError(
        context,
        AppText.t(context,
            bn: 'ইমেইল ও পাসওয়ার্ড দিন', en: 'Please enter email and password'),
      );
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await AppLoader.run<void>(
        context: context,
        message:
            AppText.t(context, bn: 'লগইন করা হচ্ছে...', en: 'Logging in...'),
        task: () => ref.read(appProviderProvider).login(email, password, role),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      UiFeedback.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Image.asset(
                'assets/images/logo.png',
                height: 130,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final p = ref.read(appProviderProvider);
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                p.languageCode == 'bn'
                                    ? Icons.check_circle
                                    : Icons.language,
                              ),
                              title: const Text('বাংলা'),
                              onTap: () => Navigator.pop(context, 'bn'),
                            ),
                            ListTile(
                              leading: Icon(
                                p.languageCode == 'en'
                                    ? Icons.check_circle
                                    : Icons.language,
                              ),
                              title: const Text('English'),
                              onTap: () => Navigator.pop(context, 'en'),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (selected != null) {
                      await p.setLanguageCode(selected);
                    }
                  },
                  icon: const Icon(Icons.language, size: 18),
                  label: Text(AppText.t(context, bn: 'ভাষা', en: 'Language')),
                ),
              ),
              const Text(
                'MessMate',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppText.t(
                  context,
                  bn: 'সহজে মেস পরিচালনা করতে লগইন করুন',
                  en: 'Login to manage your mess easily',
                ),
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: InputDecoration(
                          labelText: AppText.t(context,
                              bn: 'লগইন ধরন', en: 'Login as'),
                          prefixIcon: Icon(Icons.admin_panel_settings),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'manager',
                            child: Text(AppText.t(context,
                                bn: 'ম্যানেজার', en: 'Manager')),
                          ),
                          DropdownMenuItem(
                            value: 'member',
                            child: Text(AppText.t(context,
                                bn: 'মেম্বার', en: 'Member')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => role = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: isSubmitting ? null : login,
                        child: Text(
                          isSubmitting
                              ? AppText.t(context,
                                  bn: 'অপেক্ষা করুন...', en: 'Please wait...')
                              : AppText.t(context, bn: 'লগইন', en: 'Login'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(AppText.t(context,
                            bn: 'পাসওয়ার্ড ভুলে গেছেন?',
                            en: 'Forgot password?')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppText.t(context,
                      bn: 'অ্যাকাউন্ট নেই?', en: "Don't have an account?")),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(AppText.t(context,
                        bn: 'অ্যাকাউন্ট তৈরি করুন', en: 'Create account')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
