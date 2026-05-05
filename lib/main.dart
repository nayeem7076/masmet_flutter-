import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'features/auth/data/services/auth_token_service.dart';
import 'features/auth/presentation/viewmodels/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.validate();
  final provider = AppProvider();
  await provider.load();
  ApiClient.configure(
    tokenProvider: AuthTokenService.getAccessToken,
    onUnauthorized: provider.handleUnauthorized,
  );
  runApp(
    ProviderScope(
      overrides: [
        appProviderProvider.overrideWith((ref) => provider),
      ],
      child: const MessMateApp(),
    ),
  );
}
