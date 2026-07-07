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
}
