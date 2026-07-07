import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/event_marker_icon.dart';
import 'package:dogsafield/shared/models/event.dart';

void main() {
  group('eventTypeLabel', () {
    test('returns correct label for packWalk', () {
      expect(eventTypeLabel(EventType.packWalk), 'Pack Walk');
    });

    test('returns correct label for dogPicnic', () {
      expect(eventTypeLabel(EventType.dogPicnic), 'Dog Picnic');
    });

    test('returns correct label for fieldGames', () {
      expect(eventTypeLabel(EventType.fieldGames), 'Field Games');
    });
  });

  group('eventTypeIcon', () {
    test('returns icon for packWalk', () {
      expect(eventTypeIcon(EventType.packWalk), Icons.directions_walk);
    });

    test('returns icon for dogPicnic', () {
      expect(eventTypeIcon(EventType.dogPicnic), Icons.weekend);
    });

    test('returns icon for fieldGames', () {
      expect(eventTypeIcon(EventType.fieldGames), Icons.sports);
    });
  });

  group('markerIconForType', () {
    test('returns non-null descriptor for each event type', () {
      expect(markerIconForType(EventType.packWalk), isNotNull);
      expect(markerIconForType(EventType.dogPicnic), isNotNull);
      expect(markerIconForType(EventType.fieldGames), isNotNull);
    });

    test('returns non-null descriptor with isRsvpd true', () {
      final icon = markerIconForType(EventType.packWalk, isRsvpd: true);
      expect(icon, isNotNull);
    });

    test('returns non-null descriptor for RSVPd events of any type', () {
      expect(markerIconForType(EventType.dogPicnic, isRsvpd: true), isNotNull);
      expect(markerIconForType(EventType.fieldGames, isRsvpd: true), isNotNull);
    });
  });
}
