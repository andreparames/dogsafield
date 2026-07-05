import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/features/onboarding/presentation/welcome_screen.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('renders title and auth buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Dogs Afield'), findsOneWidget);
    expect(find.text('Because great walks are better with great company.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });
}
