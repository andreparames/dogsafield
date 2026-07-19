import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/location_provider.dart';
import '../../../shared/models/event.dart';
import '../../connections/state/connection_providers.dart';
import '../../onboarding/state/auth_provider.dart';
import '../data/field_map_repository.dart';
import 'rsvp_providers.dart';
import 'waitlist_providers.dart';

final fieldMapRepositoryProvider = Provider<FieldMapRepository>((ref) {
  return FieldMapRepository(
    Supabase.instance.client,
    ref.watch(localCacheServiceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

class RsvpFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final rsvpFilterProvider = NotifierProvider<RsvpFilterNotifier, bool>(
    RsvpFilterNotifier.new);

final allEventsProvider = FutureProvider<List<DogEvent>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final repo = ref.watch(fieldMapRepositoryProvider);
  return repo.fetchEventsNearby(
    latitude: position.latitude,
    longitude: position.longitude,
  );
});

final myTrackedEventIdsProvider = Provider<Set<String>>((ref) {
  final rsvpIds = ref.watch(myRsvpIdsProvider).value ?? {};
  final waitlistIds = ref.watch(myWaitlistWalkIdsProvider).value ?? {};
  return {...rsvpIds, ...waitlistIds};
});

final discoveredEventsProvider = Provider<List<DogEvent>>((ref) {
  final showRsvps = ref.watch(rsvpFilterProvider);
  final allEvents = ref.watch(allEventsProvider).value ?? [];
  final blockerIds = ref.watch(blockerIdsProvider).value ?? <String>{};
  final currentUserId = ref.watch(authServiceProvider).currentUser?.id;
  final visible = allEvents.where((e) => !blockerIds.contains(e.hostId)).toList();
  if (!showRsvps) return visible;
  final myIds = ref.watch(myTrackedEventIdsProvider);
  return visible.where((e) => myIds.contains(e.id) || e.hostId == currentUserId).toList();
});
