import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/providers.dart';
import '../data/rsvp_repository.dart';
import 'gathering_providers.dart';

final rsvpRepositoryProvider = Provider<RsvpRepository>((ref) {
  return RsvpRepository(
    Supabase.instance.client,
    ref.watch(localCacheServiceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

final myRsvpIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(rsvpRepositoryProvider);
  return repo.fetchMyRsvpIds();
});

final hasRsvpProvider = FutureProvider.family<bool, String>((ref, eventId) async {
  final repo = ref.watch(rsvpRepositoryProvider);
  return repo.hasRsvp(eventId);
});

sealed class RsvpActionState {
  const RsvpActionState();
}

class RsvpActionIdle extends RsvpActionState {
  const RsvpActionIdle();
}

class RsvpActionLoading extends RsvpActionState {
  const RsvpActionLoading();
}

class RsvpActionSuccess extends RsvpActionState {
  const RsvpActionSuccess();
}

class RsvpActionError extends RsvpActionState {
  final String message;
  const RsvpActionError(this.message);
}

class RsvpActionNotifier extends Notifier<RsvpActionState> {
  final String eventId;

  RsvpActionNotifier(this.eventId);

  @override
  RsvpActionState build() => const RsvpActionIdle();

  Future<void> joinPack() async {
    if (state is RsvpActionLoading) return;
    state = const RsvpActionLoading();
    try {
      final repo = ref.read(rsvpRepositoryProvider);
      await repo.rsvpToEvent(eventId);
      state = const RsvpActionSuccess();
      ref.invalidate(hasRsvpProvider(eventId));
      ref.invalidate(myRsvpIdsProvider);
      ref.invalidate(gatheringDetailProvider(eventId));
    } catch (e) {
      state = RsvpActionError('Failed to RSVP: $e');
    }
  }

  Future<void> cancelRsvp() async {
    if (state is RsvpActionLoading) return;
    state = const RsvpActionLoading();
    try {
      final repo = ref.read(rsvpRepositoryProvider);
      await repo.cancelRsvp(eventId);
      state = const RsvpActionSuccess();
      ref.invalidate(hasRsvpProvider(eventId));
      ref.invalidate(myRsvpIdsProvider);
      ref.invalidate(gatheringDetailProvider(eventId));
    } catch (e) {
      state = RsvpActionError('Failed to cancel RSVP: $e');
    }
  }

  void reset() => state = const RsvpActionIdle();
}

final rsvpActionProvider =
    NotifierProvider.family<RsvpActionNotifier, RsvpActionState, String>(
  (eventId) => RsvpActionNotifier(eventId),
);
