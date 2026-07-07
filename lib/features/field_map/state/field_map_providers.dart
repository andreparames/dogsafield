import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/location_provider.dart';
import '../../../shared/models/event.dart';
import '../data/field_map_repository.dart';
import 'rsvp_providers.dart';

final fieldMapRepositoryProvider = Provider<FieldMapRepository>((ref) {
  return FieldMapRepository(Supabase.instance.client);
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

final discoveredEventsProvider = FutureProvider<List<DogEvent>>((ref) async {
  final showRsvps = ref.watch(rsvpFilterProvider);
  final allEvents = await ref.watch(allEventsProvider.future);
  if (!showRsvps) return allEvents;
  final rsvpIds = await ref.watch(myRsvpIdsProvider.future);
  return allEvents.where((e) => rsvpIds.contains(e.id)).toList();
});
