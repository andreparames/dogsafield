import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import 'database.dart';
import 'local_cache_service.dart';

final localDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main()');
});

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  final db = ref.watch(localDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalCacheService(db: db, prefs: prefs);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onStatusChanged;
});

final isOnlineProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnline;
});
