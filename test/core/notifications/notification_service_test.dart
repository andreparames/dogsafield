import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:dogsafield/core/notifications/notification_service.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'mocks.mocks.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;
  late SharedPreferences prefs;
  late NotificationService service;

  setUp(() async {
    tz.initializeTimeZones();
    plugin = MockFlutterLocalNotificationsPlugin();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = NotificationService(plugin, prefs);
  });

  group('scheduleRollCallReminder', () {
    test('schedules a future reminder', () async {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      await service.scheduleRollCallReminder(
        eventId: 'evt_1',
        eventDateTime: futureDate,
        eventTitle: 'Pack Walk',
      );

      verify(plugin.zonedSchedule(
        'evt_1'.hashCode,
        "Who'd you meet?",
        'You attended Pack Walk — check who you met!',
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: 'evt_1',
      )).called(1);

      final stored = prefs.getString('notif_event_${'evt_1'.hashCode}');
      expect(stored, isNotNull);
      final decoded = jsonDecode(stored!) as Map<String, dynamic>;
      expect(decoded['eventId'], equals('evt_1'));
      expect(decoded['eventTitle'], equals('Pack Walk'));
    });

    test('skips scheduling when reminder time is in the past', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      await service.scheduleRollCallReminder(
        eventId: 'evt_1',
        eventDateTime: pastDate,
        eventTitle: 'Past Event',
      );

      verifyNever(plugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: anyNamed('payload'),
      ));

      expect(prefs.containsKey('notif_event_${'evt_1'.hashCode}'), isFalse);
    });
  });

  group('cancelRollCallReminder', () {
    test('cancels and removes stored data', () async {
      await prefs.setString(
        'notif_event_${'evt_1'.hashCode}',
        '{"eventId":"evt_1"}',
      );

      await service.cancelRollCallReminder('evt_1');

      verify(plugin.cancel('evt_1'.hashCode)).called(1);
      expect(
        prefs.containsKey('notif_event_${'evt_1'.hashCode}'),
        isFalse,
      );
    });
  });

  group('getEventIdFromPayload', () {
    test('returns the payload as-is', () {
      expect(service.getEventIdFromPayload('abc'), equals('abc'));
      expect(service.getEventIdFromPayload(null), isNull);
    });
  });

  group('reschedulePending', () {
    test('re-schedules future entries and skips past ones', () async {
      final futureTime = DateTime.now()
          .add(const Duration(hours: 3))
          .toIso8601String();
      final pastTime = DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String();

      await prefs.setString(
        'notif_event_1',
        '{"eventId":"evt_1","eventTitle":"Future Walk","scheduleTime":"$futureTime"}',
      );
      await prefs.setString(
        'notif_event_2',
        '{"eventId":"evt_2","eventTitle":"Past Walk","scheduleTime":"$pastTime"}',
      );

      await service.reschedulePending();

      verify(plugin.zonedSchedule(
        'evt_1'.hashCode,
        "Who'd you meet?",
        'You attended Future Walk — check who you met!',
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: 'evt_1',
      )).called(1);

      expect(prefs.containsKey('notif_event_2'), isFalse);
    });

    test('recovers legacy plain-string entries via eventLookup', () async {
      final futureDate = DateTime.now().add(const Duration(days: 1));

      await prefs.setString('notif_event_99', 'legacy_evt_id');

      final lookupService = NotificationService(
        plugin,
        prefs,
        eventLookup: (id) async {
          if (id == 'legacy_evt_id') {
            return DogEvent(
              id: 'legacy_evt_id',
              hostId: 'host1',
              type: EventType.packWalk,
              title: 'Recovered Walk',
              locationName: 'Park',
              latitude: 0,
              longitude: 0,
              dateTime: futureDate,
              maxAttendees: 10,
            );
          }
          return null;
        },
      );

      await lookupService.reschedulePending();

      verify(plugin.zonedSchedule(
        'legacy_evt_id'.hashCode,
        "Who'd you meet?",
        'You attended Recovered Walk — check who you met!',
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: 'legacy_evt_id',
      )).called(1);

      final stored =
          prefs.getString('notif_event_${'legacy_evt_id'.hashCode}');
      expect(stored, isNotNull);
      final decoded = jsonDecode(stored!) as Map<String, dynamic>;
      expect(decoded['eventId'], equals('legacy_evt_id'));
      expect(decoded['eventTitle'], equals('Recovered Walk'));
    });

    test('removes legacy entries when eventLookup is null', () async {
      await prefs.setString('notif_event_99', 'legacy_evt_id');

      await service.reschedulePending();

      verifyNever(plugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: anyNamed('payload'),
      ));

      expect(prefs.containsKey('notif_event_99'), isFalse);
    });

    test('removes legacy entries when eventLookup returns null', () async {
      await prefs.setString('notif_event_99', 'legacy_evt_id');

      final lookupService = NotificationService(
        plugin,
        prefs,
        eventLookup: (id) async => null,
      );

      await lookupService.reschedulePending();

      verifyNever(plugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: anyNamed('payload'),
      ));

      expect(prefs.containsKey('notif_event_99'), isFalse);
    });

    test('removes legacy entries when the event is in the past', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      await prefs.setString('notif_event_99', 'legacy_evt_id');

      final lookupService = NotificationService(
        plugin,
        prefs,
        eventLookup: (id) async => DogEvent(
          id: 'legacy_evt_id',
          hostId: 'host1',
          type: EventType.packWalk,
          title: 'Past Event',
          locationName: 'Park',
          latitude: 0,
          longitude: 0,
          dateTime: pastDate,
          maxAttendees: 10,
        ),
      );

      await lookupService.reschedulePending();

      verifyNever(plugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: anyNamed('payload'),
      ));

      expect(prefs.containsKey('notif_event_99'), isFalse);
    });
  });
}
