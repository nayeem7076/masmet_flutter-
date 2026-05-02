import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  String role = 'manager';

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final phoneOrEmail = phoneController.text.trim().isEmpty
        ? '01700000000'
        : phoneController.text.trim();

    await ref.read(appProviderProvider).login(phoneOrEmail, role);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
              const Text(
                'Welcome to MessMate',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Login to manage your mess easily',
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
                        controller: phoneController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email or Phone Number',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Login as',
                          prefixIcon: Icon(Icons.admin_panel_settings),
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
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: login,
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Create account'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Demo OTP: 1234',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
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
