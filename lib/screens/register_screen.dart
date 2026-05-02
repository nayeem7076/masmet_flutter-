import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ui/ui_feedback.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String role = 'member';
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      UiFeedback.showError(context, 'Please enter name and email/phone');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await ref.read(appProviderProvider).register(name, phone, role);
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
      appBar: AppBar(title: const Text('Create Account')),
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
              const Text(
                'Join MessMate',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create your account to manage mess easily',
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
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email or Phone Number',
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Account Role',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'manager', child: Text('Manager')),
                          DropdownMenuItem(
                              value: 'member', child: Text('Member')),
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
                        label:
                            Text(isSubmitting ? 'Please wait...' : 'Register'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                role == 'manager'
                    ? 'Manager can add, edit and delete mess data.'
                    : 'Member can view meals, cost and balance.',
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
