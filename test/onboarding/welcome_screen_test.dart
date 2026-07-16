import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/welcome_screen.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('renders logo, tagline and auth buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Because great walks are better with great company.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });

  testWidgets('logo tap counter reaches 7 and navigates to reviewer login',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const WelcomeScreen()));
    await tester.pumpAndSettle();

    final logo = find.byKey(const Key('welcomeLogo'));

    // Tap 6 times — should not trigger navigation.
    for (var i = 0; i < 6; i++) {
      await tester.tap(logo);
      await tester.pump();
    }

    // 7th tap triggers GoRouter push to reviewer-login.
    await tester.tap(logo);
    await tester.pumpAndSettle();

    expect(find.text('Reviewer Login'), findsOneWidget);
  });
}
