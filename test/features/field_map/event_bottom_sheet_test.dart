import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/event_bottom_sheet.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import 'package:dogsafield/features/field_map/state/gathering_providers.dart';
import 'package:dogsafield/shared/models/event.dart';

Widget _wrap({required Widget child}) {
  LocaleSettings.setLocaleSync(AppLocale.en);
  return ProviderScope(
    overrides: [
      attendanceCountProvider.overrideWith((ref, eventId) async => 3),
    ],
    child: TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(height: 600, child: child),
        ),
      ),
    ),
  );
}

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
      await tester.pumpWidget(_wrap(child: EventBottomSheet(event: testEvent)));

      expect(find.text('Riverside Pack Walk'), findsOneWidget);
    });

    testWidgets('displays event type label', (tester) async {
      await tester.pumpWidget(_wrap(child: EventBottomSheet(event: testEvent)));

      expect(find.text(t.event.type.packWalk), findsOneWidget);
    });

    testWidgets('displays location name', (tester) async {
      await tester.pumpWidget(_wrap(child: EventBottomSheet(event: testEvent)));

      expect(find.text('Riverside Park'), findsOneWidget);
    });

    testWidgets('displays attendee count', (tester) async {
      await tester.pumpWidget(_wrap(child: EventBottomSheet(event: testEvent)));
      await tester.pump();

      expect(find.text('3 / 20'), findsOneWidget);
    });

    testWidgets('displays amenity tags as chips', (tester) async {
      await tester.pumpWidget(_wrap(child: EventBottomSheet(event: testEvent)));

      expect(find.text('Heavy Shade'), findsOneWidget);
      expect(find.text('Fenced Area'), findsOneWidget);
    });

    testWidgets('shows View Details button immediately without scrolling', (tester) async {
      await tester.pumpWidget(_wrap(child: EventBottomSheet(event: testEvent)));

      expect(find.text(t.fieldMap.viewDetails), findsOneWidget);
    });

    testWidgets('does not show Leave Pack when showRsvpAction is false', (tester) async {
      await tester.pumpWidget(
        _wrap(child: EventBottomSheet(event: testEvent, showRsvpAction: false)),
      );

      expect(find.text(t.fieldMap.leavePack), findsNothing);
    });

    testWidgets('shows Leave Pack when showRsvpAction is true', (tester) async {
      await tester.pumpWidget(
        _wrap(child: EventBottomSheet(event: testEvent, showRsvpAction: true)),
      );

      expect(find.text(t.fieldMap.leavePack), findsOneWidget);
    });
  });
}
