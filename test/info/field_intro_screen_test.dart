import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/info/presentation/field_intro_screen.dart';
import '../helpers/test_utils.dart';

Widget createInfoApp() {
  return createTestApp(const FieldIntroScreen());
}

void main() {
  setUp(() {
    fakeAccountRepository.fieldIntroSeenCount = 0;
    fakeAccountRepository.hostIntroSeenCount = 0;
  });

  group('FieldIntroScreen', () {
    testWidgets('displays title and illustration', (tester) async {
      await tester.pumpWidget(createInfoApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to the Field'), findsWidgets);
      expect(find.text('Explore Dog-Friendly Events'), findsOneWidget);
    });

    testWidgets('displays all tip cards', (tester) async {
      await tester.pumpWidget(createInfoApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Browse the map'), 100);
      expect(find.text('Browse the map'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('RSVP to join'), 100);
      expect(find.text('RSVP to join'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Host your own'), 100);
      expect(find.text('Host your own'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Send feedback'), 100);
      expect(find.text('Send feedback'), findsOneWidget);
    });

    testWidgets('tapping Got It navigates to /', (tester) async {
      await tester.pumpWidget(createInfoApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Got It'), 100);
      expect(find.text('Got It'), findsOneWidget);

      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
