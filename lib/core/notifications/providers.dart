import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../database/providers.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final cache = ref.watch(localCacheServiceProvider);
  return NotificationService(
    FlutterLocalNotificationsPlugin(),
    prefs,
    eventLookup: cache.getEventById,
  );
});
