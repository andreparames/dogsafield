import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/database/providers.dart';
import 'core/notifications/providers.dart';
import 'core/notifications/notification_service.dart';
import 'features/onboarding/state/auth_provider.dart';
import 'routes.dart' show navigateToEvent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const key = String.fromEnvironment('SUPABASE_PUB_KEY', defaultValue: '');

  if (url.isEmpty || key.isEmpty) {
    throw StateError(
      'Supabase credentials not set. '
      'Pass --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUB_KEY=...',
    );
  }

  await Supabase.initialize(url: url, publishableKey: key);

  Supabase.instance.client.auth.onAuthStateChange.listen((_) {
    authRefreshNotifier.value++;
  });

  final prefs = await SharedPreferences.getInstance();

  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
    prefs,
    onNotificationTap: navigateToEvent,
  );
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const DogsAfieldApp(),
    ),
  );
}
