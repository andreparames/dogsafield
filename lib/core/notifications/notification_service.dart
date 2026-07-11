import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final SharedPreferences _prefs;
  final void Function(String eventId)? onNotificationTap;

  NotificationService(this._plugin, this._prefs, {this.onNotificationTap});

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
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: eventId,
    );

    await _prefs.setString('notif_event_$id', eventId);
  }

  Future<void> cancelRollCallReminder(String eventId) async {
    final id = eventId.hashCode;
    await _plugin.cancel(id);
    await _prefs.remove('notif_event_$id');
  }

  String? getEventIdFromPayload(String? payload) => payload;

  Future<void> reschedulePending() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('notif_event_'));
    for (final key in keys) {
      final eventId = _prefs.getString(key);
      if (eventId != null) {
        // Re-schedule will be handled when the event detail is viewed
      }
    }
  }
}
