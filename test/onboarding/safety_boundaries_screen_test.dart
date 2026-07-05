import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/safety_boundaries_screen.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('shows snackbar when no treat policy selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SafetyBoundariesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Please select a treat policy'), findsOneWidget);
  });

  testWidgets('renders treat policy options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SafetyBoundariesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Safety Boundaries'), findsOneWidget);
    expect(find.text('Treat Policy'), findsOneWidget);
    expect(find.textContaining('Okay to share'), findsOneWidget);
    expect(find.textContaining('Ask before feeding'), findsOneWidget);
    expect(find.text('Complete Profile'), findsOneWidget);
  });
}
