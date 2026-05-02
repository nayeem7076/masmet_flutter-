import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.load();
  runApp(
    ProviderScope(
      overrides: [
        appProviderProvider.overrideWith((ref) => provider),
      ],
      child: const MessMateApp(),
    ),
  );
}
