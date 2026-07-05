import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/icebreaker_screen.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('shows snackbar when no prompt selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const IcebreakerScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please select a prompt'), findsOneWidget);
  });

  testWidgets('shows snackbar when answer is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const IcebreakerScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My dog\'s greatest criminal achievement to date...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please share your story'), findsOneWidget);
  });

  testWidgets('renders all prompts', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const IcebreakerScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Pick a prompt and share a story'), findsOneWidget);
    expect(find.text('My dog\'s greatest criminal achievement to date...'), findsOneWidget);
    expect(find.text('The weirdest thing my dog is afraid of...'), findsOneWidget);
    expect(find.text('If my dog had a job, it would be...'), findsOneWidget);
    expect(find.text('My dog\'s favorite snack that isn\'t dog food...'), findsOneWidget);
  });
}
