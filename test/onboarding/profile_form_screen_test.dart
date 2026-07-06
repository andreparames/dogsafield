import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/profile_form_screen.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('shows snackbar when name is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ProfileFormScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your dog\'s name'), findsOneWidget);
  });

  testWidgets('renders all form fields', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ProfileFormScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Pup Profile'), findsOneWidget);
    expect(find.text('Dog\'s Name'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Breed'), findsOneWidget);
    expect(find.text('Social Vibe'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('renders all vibe options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ProfileFormScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Lounge Lizard'), findsOneWidget);
    expect(find.textContaining('Zoomie King'), findsOneWidget);
    expect(find.textContaining('Social Learner'), findsOneWidget);
  });
}
