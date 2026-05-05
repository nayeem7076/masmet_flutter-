import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:messmate_app_full/app.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

void main() {
  testWidgets('App renders splash branding', (WidgetTester tester) async {
    final provider = AppProvider();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appProviderProvider.overrideWith((ref) => provider),
        ],
        child: const MessMateApp(),
      ),
    );

    await tester.pump();

    expect(find.text('MessMate'), findsOneWidget);
  });
}
