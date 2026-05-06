import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

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
      appBar: AppBar(
        title: Text(AppText.t(context,
            bn: 'পাসওয়ার্ড ভুলে গেছেন', en: 'Forgot Password')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phone,
              decoration: InputDecoration(
                labelText:
                    AppText.t(context, bn: 'ফোন নম্বর', en: 'Phone Number'),
              ),
            ),
            const SizedBox(height: 12),
            if (sent)
              TextField(
                controller: otp,
                decoration: InputDecoration(
                  labelText:
                      AppText.t(context, bn: 'ওটিপি কোড', en: 'OTP Code'),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (!sent) {
                  if (phone.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppText.t(
                            context,
                            bn: 'ফোন নম্বর বা ইমেইল দিন',
                            en: 'Please enter phone or email',
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                  ref.read(appProviderProvider).sendOtp(phone.text.trim());
                  setState(() => sent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppText.t(context,
                            bn: 'ওটিপি সফলভাবে পাঠানো হয়েছে',
                            en: 'OTP sent successfully'),
                      ),
                    ),
                  );
                } else {
                  if (otp.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppText.t(context,
                            bn: 'ওটিপি দিন', en: 'Please enter OTP')),
                      ),
                    );
                    return;
                  }
                  final ok = await ref
                      .read(appProviderProvider)
                      .verifyOtp(otp.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? AppText.t(
                                context,
                                bn: 'ওটিপি যাচাই হয়েছে। এখন লগইন করতে পারবেন।',
                                en: 'OTP verified. You can login now.',
                              )
                            : AppText.t(context,
                                bn: 'ভুল ওটিপি', en: 'Wrong OTP'),
                      ),
                    ),
                  );
                  if (ok) Navigator.pop(context);
                }
              },
              child: Text(
                sent
                    ? AppText.t(context, bn: 'ওটিপি যাচাই', en: 'Verify OTP')
                    : AppText.t(context, bn: 'ওটিপি পাঠান', en: 'Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
