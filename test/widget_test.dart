import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/app.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'helpers/test_utils.dart';

void main() {
  testWidgets('App renders welcome screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
        ],
        child: const DogsAfieldApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dogs Afield'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
