import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/location_provider.dart';
import '../../../shared/models/event.dart';
import '../../connections/state/connection_providers.dart';
import '../data/field_map_repository.dart';
import 'rsvp_providers.dart';

final fieldMapRepositoryProvider = Provider<FieldMapRepository>((ref) {
  return FieldMapRepository(
    Supabase.instance.client,
    ref.watch(localCacheServiceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

final rsvpFilterProvider = StateProvider<bool>((ref) => false);

final allEventsProvider = FutureProvider<List<DogEvent>>((ref) async {
  final repo = ref.watch(fieldMapRepositoryProvider);
  final position = await ref.watch(currentPositionProvider.future);
  return repo.fetchEventsNearby(
    latitude: position.latitude,
    longitude: position.longitude,
  );
});

final discoveredEventsProvider = Provider<List<DogEvent>>((ref) {
  final showRsvps = ref.watch(rsvpFilterProvider);
  final allEvents = ref.watch(allEventsProvider).valueOrNull ?? [];
  final blockedIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? <String>{};
  final visible = allEvents.where((e) => !blockedIds.contains(e.hostId)).toList();
  if (!showRsvps) return visible;
  final rsvpIds = ref.watch(myRsvpIdsProvider).valueOrNull ?? {};
  return visible.where((e) => rsvpIds.contains(e.id)).toList();
});
