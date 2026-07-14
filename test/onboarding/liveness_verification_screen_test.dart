import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/liveness_verification_screen.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('renders liveness screen with title and next button', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const LivenessVerificationScreen()));
    await tester.pumpAndSettle();

    expect(find.text(t.onboarding.liveness.title), findsOneWidget);
    expect(find.text(t.onboarding.liveness.subtitle), findsOneWidget);
    expect(find.text(t.onboarding.liveness.hint), findsOneWidget);
    expect(find.text(t.common.next), findsOneWidget);
    expect(find.text(t.common.cancel), findsOneWidget);
  });

  testWidgets('cancel navigates away from liveness screen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const LivenessVerificationScreen()));
    await tester.pumpAndSettle();

    expect(find.text(t.onboarding.liveness.title), findsOneWidget);

    await tester.tap(find.text(t.common.cancel));
    await tester.pumpAndSettle();

    expect(find.text(t.onboarding.liveness.title), findsNothing);
  });
}
