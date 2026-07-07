import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/gathering_details_screen.dart';

void main() {
  group('GatheringDetailsScreen', () {
    testWidgets('displays event ID', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GatheringDetailsScreen(eventId: 'test-event-123'),
        ),
      );

      expect(find.text('ID: test-event-123'), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GatheringDetailsScreen(eventId: 'abc'),
        ),
      );

      expect(find.text('Gathering Details'), findsOneWidget);
    });

    testWidgets('shows placeholder message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GatheringDetailsScreen(eventId: 'xyz'),
        ),
      );

      expect(find.text('Full event details coming soon.'), findsOneWidget);
    });
  });
}
