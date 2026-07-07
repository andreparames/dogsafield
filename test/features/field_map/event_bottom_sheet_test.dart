import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/event_bottom_sheet.dart';
import 'package:dogsafield/shared/models/event.dart';

void main() {
  final testEvent = DogEvent(
    id: 'abc-123',
    hostId: 'host-1',
    type: EventType.packWalk,
    title: 'Riverside Pack Walk',
    description: 'A lovely walk along the river.',
    locationName: 'Riverside Park',
    latitude: 38.7,
    longitude: -9.1,
    dateTime: DateTime(2026, 7, 10, 15, 0),
    maxAttendees: 20,
    attendeeIds: ['user-1', 'user-2', 'user-3'],
    amenityTags: ['Heavy Shade', 'Fenced Area'],
    whatToBring: ['Water', 'Long leash'],
  );

  group('EventBottomSheet', () {
    testWidgets('displays event title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent),
            ),
          ),
        ),
      );

      expect(find.text('Riverside Pack Walk'), findsOneWidget);
    });

    testWidgets('displays event type label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent),
            ),
          ),
        ),
      );

      expect(find.text('Pack Walk'), findsOneWidget);
    });

    testWidgets('displays location name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent),
            ),
          ),
        ),
      );

      expect(find.text('Riverside Park'), findsOneWidget);
    });

    testWidgets('displays attendee count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('3 / 20'), findsOneWidget);
    });

    testWidgets('displays amenity tags as chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('Heavy Shade'), findsOneWidget);
      expect(find.text('Fenced Area'), findsOneWidget);
    });

    testWidgets('shows View Details button immediately without scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent),
            ),
          ),
        ),
      );

      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('does not show Cancel RSVP when showRsvpAction is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent, showRsvpAction: false),
            ),
          ),
        ),
      );

      expect(find.text('Cancel RSVP'), findsNothing);
    });

    testWidgets('shows Cancel RSVP when showRsvpAction is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: EventBottomSheet(event: testEvent, showRsvpAction: true),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.text('Cancel RSVP'), findsOneWidget);
    });
  });
}
