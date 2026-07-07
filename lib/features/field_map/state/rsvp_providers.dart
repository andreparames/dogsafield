import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/rsvp_repository.dart';

final rsvpRepositoryProvider = Provider<RsvpRepository>((ref) {
  return RsvpRepository(Supabase.instance.client);
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

class RsvpActionNotifier extends StateNotifier<RsvpActionState> {
  final Ref _ref;
  final String _eventId;

  RsvpActionNotifier(this._ref, this._eventId)
      : super(const RsvpActionIdle());

  Future<void> joinPack() async {
    if (state is RsvpActionLoading) return;
    state = const RsvpActionLoading();
    try {
      final repo = _ref.read(rsvpRepositoryProvider);
      await repo.rsvpToEvent(_eventId);
      state = const RsvpActionSuccess();
      _ref.invalidate(hasRsvpProvider(_eventId));
    } catch (e) {
      state = RsvpActionError('Failed to RSVP: $e');
    }
  }

  Future<void> cancelRsvp() async {
    if (state is RsvpActionLoading) return;
    state = const RsvpActionLoading();
    try {
      final repo = _ref.read(rsvpRepositoryProvider);
      await repo.cancelRsvp(_eventId);
      state = const RsvpActionSuccess();
      _ref.invalidate(hasRsvpProvider(_eventId));
    } catch (e) {
      state = RsvpActionError('Failed to cancel RSVP: $e');
    }
  }

  void reset() => state = const RsvpActionIdle();
}

final rsvpActionProvider =
    StateNotifierProvider.family<RsvpActionNotifier, RsvpActionState, String>(
  (ref, eventId) => RsvpActionNotifier(ref, eventId),
);
