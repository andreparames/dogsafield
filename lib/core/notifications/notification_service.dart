import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../shared/models/event.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final SharedPreferences _prefs;
  final void Function(String eventId)? onNotificationTap;
  final Future<DogEvent?> Function(String eventId)? _eventLookup;

  NotificationService(
    this._plugin,
    this._prefs, {
    this.onNotificationTap,
    Future<DogEvent?> Function(String eventId)? eventLookup,
  }) : _eventLookup = eventLookup;

  static const _channelId = 'roll_call_channel';
  static const _channelName = 'Roll Call Reminders';
  static const _channelDesc = 'Reminders to complete roll call after an event';

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await reschedulePending();
  }

  void _onNotificationResponse(NotificationResponse response) {
    final eventId = response.payload;
    if (eventId != null) {
      onNotificationTap?.call(eventId);
    }
  }

  Future<void> scheduleRollCallReminder({
    required String eventId,
    required DateTime eventDateTime,
    required String eventTitle,
  }) async {
    final now = DateTime.now();
    final scheduleTime = eventDateTime.add(const Duration(hours: 2));
    if (scheduleTime.isBefore(now)) return;

    await _zonedSchedule(
      eventId: eventId,
      eventTitle: eventTitle,
      scheduleTime: scheduleTime,
    );

    final id = eventId.hashCode;
    await _prefs.setString(
      'notif_event_$id',
      jsonEncode({
        'eventId': eventId,
        'eventTitle': eventTitle,
        'scheduleTime': scheduleTime.toIso8601String(),
      }),
    );
  }

  Future<void> _zonedSchedule({
    required String eventId,
    required String eventTitle,
    required DateTime scheduleTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = eventId.hashCode;
    final tzScheduledTime = tz.TZDateTime.from(scheduleTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      'Who\'d you meet?',
      'You attended $eventTitle — check who you met!',
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: eventId,
    );
  }

  Future<void> cancelRollCallReminder(String eventId) async {
    final id = eventId.hashCode;
    await _plugin.cancel(id);
    await _prefs.remove('notif_event_$id');
  }

  String? getEventIdFromPayload(String? payload) => payload;

  /// Re-registers OS-level alarms for reminders that were previously
  /// scheduled, e.g. after a device reboot clears Android's AlarmManager
  /// entries. Stale entries whose fire time has already passed are cleaned
  /// up instead of being rescheduled.
  Future<void> reschedulePending() async {
    final keys =
        _prefs.getKeys().where((k) => k.startsWith('notif_event_')).toList();
    final now = DateTime.now();

    for (final key in keys) {
      final raw = _prefs.getString(key);
      if (raw == null) continue;

      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final eventId = data['eventId'] as String;
        final eventTitle = data['eventTitle'] as String;
        final scheduleTime = DateTime.parse(data['scheduleTime'] as String);

        if (scheduleTime.isBefore(now)) {
          await _prefs.remove(key);
          continue;
        }

        await _zonedSchedule(
          eventId: eventId,
          eventTitle: eventTitle,
          scheduleTime: scheduleTime,
        );
      } catch (_) {
        if (_eventLookup != null) {
          final event = await _eventLookup!(raw);
          if (event != null) {
            final scheduleTime =
                event.dateTime.add(const Duration(hours: 2));
            if (!scheduleTime.isBefore(now)) {
              await _zonedSchedule(
                eventId: event.id,
                eventTitle: event.title,
                scheduleTime: scheduleTime,
              );
              final id = event.id.hashCode;
              await _prefs.setString(
                'notif_event_$id',
                jsonEncode({
                  'eventId': event.id,
                  'eventTitle': event.title,
                  'scheduleTime': scheduleTime.toIso8601String(),
                }),
              );
              continue;
            }
          }
        }
        await _prefs.remove(key);
      }
    }
  }
}
