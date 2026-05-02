import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  bool sent = false;

  @override
  void dispose() {
    phone.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 12),
            if (sent)
              TextField(
                controller: otp,
                decoration: const InputDecoration(labelText: 'OTP Code'),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (!sent) {
                  ref.read(appProviderProvider).sendOtp(phone.text);
                  setState(() => sent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mock OTP sent: 1234')),
                  );
                } else {
                  final ok = await ref
                      .read(appProviderProvider)
                      .verifyOtp(otp.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? 'OTP verified. You can login now.' : 'Wrong OTP',
                      ),
                    ),
                  );
                  if (ok) Navigator.pop(context);
                }
              },
              child: Text(sent ? 'Verify OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
