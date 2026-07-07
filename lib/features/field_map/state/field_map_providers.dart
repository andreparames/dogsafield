import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/location_provider.dart';
import '../../../shared/models/event.dart';
import '../data/field_map_repository.dart';

final fieldMapRepositoryProvider = Provider<FieldMapRepository>((ref) {
  return FieldMapRepository(Supabase.instance.client);
});

final rsvpFilterProvider = StateProvider<bool>((ref) => false);

final discoveredEventsProvider = FutureProvider<List<DogEvent>>((ref) async {
  final repo = ref.watch(fieldMapRepositoryProvider);
  final showRsvps = ref.watch(rsvpFilterProvider);
  if (showRsvps) {
    return repo.fetchMyRsvps();
  }
  final position = await ref.watch(currentPositionProvider.future);
  return repo.fetchEventsNearby(
    latitude: position.latitude,
    longitude: position.longitude,
  );
});
