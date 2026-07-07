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

enum RsvpActionState { idle, loading, success, error }

class RsvpActionNotifier extends StateNotifier<RsvpActionState> {
  final Ref _ref;
  final String _eventId;

  RsvpActionNotifier(this._ref, this._eventId) : super(RsvpActionState.idle);

  Future<void> joinPack() async {
    state = RsvpActionState.loading;
    try {
      final repo = _ref.read(rsvpRepositoryProvider);
      await repo.rsvpToEvent(_eventId);
      state = RsvpActionState.success;
      _ref.invalidate(hasRsvpProvider(_eventId));
    } catch (e) {
      state = RsvpActionState.error;
    }
  }

  Future<void> cancelRsvp() async {
    state = RsvpActionState.loading;
    try {
      final repo = _ref.read(rsvpRepositoryProvider);
      await repo.cancelRsvp(_eventId);
      state = RsvpActionState.success;
      _ref.invalidate(hasRsvpProvider(_eventId));
    } catch (e) {
      state = RsvpActionState.error;
    }
  }

  void reset() => state = RsvpActionState.idle;
}

final rsvpActionProvider =
    StateNotifierProvider.family<RsvpActionNotifier, RsvpActionState, String>(
  (ref, eventId) => RsvpActionNotifier(ref, eventId),
);
