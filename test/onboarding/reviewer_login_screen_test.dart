import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/reviewer_login_screen.dart';
import '../helpers/test_utils.dart';

void main() {
  setUp(() {
    fakeAuthService.reviewerEmailForCode = null;
    fakeAuthService.signInShouldFail = false;
    fakeAuthService.lastSignInEmail = null;
    fakeAuthService.lastSignInPassword = null;
  });

  testWidgets('renders title, subtitle, code field and sign-in button',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ReviewerLoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Reviewer Access'), findsOneWidget);
    expect(find.text('Enter the access code provided by the team.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('valid code signs in with the email returned by the RPC',
      (WidgetTester tester) async {
    fakeAuthService.reviewerEmailForCode = 'reviewer@test.com';

    await tester.pumpWidget(createTestApp(const ReviewerLoginScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'VALID123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.lastSignInEmail, 'reviewer@test.com');
    expect(fakeAuthService.lastSignInPassword, 'VALID123');
  });

  testWidgets('invalid code shows error snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ReviewerLoginScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'BADCODE');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid or expired access code.'), findsOneWidget);
    expect(fakeAuthService.lastSignInEmail, isNull);
  });
}
