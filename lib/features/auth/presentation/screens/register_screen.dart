import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/core/ui/ui_feedback.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/home/presentation/screens/home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'member';
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      UiFeedback.showError(
        context,
        AppText.t(
          context,
          bn: 'নাম, ইমেইল ও পাসওয়ার্ড দিন',
          en: 'Please enter name, email and password',
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await ref.read(appProviderProvider).register(name, email, password, role);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
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
      appBar: AppBar(
        title: Text(
            AppText.t(context, bn: 'অ্যাকাউন্ট তৈরি', en: 'Create Account')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset(
                'assets/images/logo.png',
                height: 115,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              Text(
                AppText.t(context, bn: 'মেসমেটে যোগ দিন', en: 'Join MessMate'),
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppText.t(
                  context,
                  bn: 'সহজে মেস পরিচালনার জন্য আপনার অ্যাকাউন্ট তৈরি করুন',
                  en: 'Create your account to manage mess easily',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 24),
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
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppText.t(context,
                              bn: 'পূর্ণ নাম', en: 'Full Name'),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText:
                              AppText.t(context, bn: 'ইমেইল', en: 'Email'),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!isSubmitting) register();
                        },
                        decoration: InputDecoration(
                          labelText: AppText.t(context,
                              bn: 'পাসওয়ার্ড', en: 'Password'),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: InputDecoration(
                          labelText: AppText.t(context,
                              bn: 'অ্যাকাউন্ট ধরন', en: 'Account Role'),
                          prefixIcon: Icon(Icons.badge_outlined),
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
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: isSubmitting ? null : register,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          isSubmitting
                              ? AppText.t(context,
                                  bn: 'অপেক্ষা করুন...', en: 'Please wait...')
                              : AppText.t(context,
                                  bn: 'রেজিস্টার', en: 'Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                role == 'manager'
                    ? AppText.t(
                        context,
                        bn: 'ম্যানেজার মেসের তথ্য যোগ, সম্পাদনা ও মুছতে পারবেন।',
                        en: 'Manager can add, edit and delete mess data.',
                      )
                    : AppText.t(
                        context,
                        bn: 'মেম্বার মিল, খরচ ও ব্যালান্স দেখতে পারবেন।',
                        en: 'Member can view meals, cost and balance.',
                      ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
