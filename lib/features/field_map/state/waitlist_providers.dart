import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/waitlist_repository.dart';
import 'package:dogsafield/i18n/strings.g.dart';

final waitlistRepositoryProvider = Provider<WaitlistRepository>((ref) {
  return WaitlistRepository(Supabase.instance.client);
});

final myWaitlistStatusProvider =
    FutureProvider.family.autoDispose<WaitlistEntry?, String>((ref, walkId) async {
  final repo = ref.watch(waitlistRepositoryProvider);
  return repo.fetchMyStatus(walkId);
});

final waitlistCountsProvider =
    FutureProvider.family.autoDispose<Map<String, int>, String>((ref, walkId) async {
  final repo = ref.watch(waitlistRepositoryProvider);
  return repo.fetchCounts(walkId);
});

sealed class WaitlistActionState {
  const WaitlistActionState();
}

class WaitlistActionIdle extends WaitlistActionState {
  const WaitlistActionIdle();
}

class WaitlistActionLoading extends WaitlistActionState {
  const WaitlistActionLoading();
}

class WaitlistActionSuccess extends WaitlistActionState {
  const WaitlistActionSuccess();
}

class WaitlistActionError extends WaitlistActionState {
  final String message;
  const WaitlistActionError(this.message);
}

class WaitlistActionNotifier extends Notifier<WaitlistActionState> {
  final String walkId;

  WaitlistActionNotifier(this.walkId);

  @override
  WaitlistActionState build() => const WaitlistActionIdle();

  Future<void> joinWaitlist() async {
    if (state is WaitlistActionLoading) return;
    state = const WaitlistActionLoading();
    try {
      final repo = ref.read(waitlistRepositoryProvider);
      await repo.joinWaitlist(walkId);
      state = const WaitlistActionSuccess();
      ref.invalidate(myWaitlistStatusProvider(walkId));
      ref.invalidate(waitlistCountsProvider(walkId));
    } catch (e) {
      state = WaitlistActionError(t.errors.failedToRsvp(error: e));
    }
  }

  Future<void> confirmSpot() async {
    if (state is WaitlistActionLoading) return;
    state = const WaitlistActionLoading();
    try {
      final repo = ref.read(waitlistRepositoryProvider);
      await repo.confirmSpot(walkId);
      state = const WaitlistActionSuccess();
      ref.invalidate(myWaitlistStatusProvider(walkId));
      ref.invalidate(waitlistCountsProvider(walkId));
    } catch (e) {
      state = WaitlistActionError(t.errors.failedToRsvp(error: e));
    }
  }

  Future<void> leaveWaitlist() async {
    if (state is WaitlistActionLoading) return;
    state = const WaitlistActionLoading();
    try {
      final repo = ref.read(waitlistRepositoryProvider);
      await repo.leaveWaitlist(walkId);
      state = const WaitlistActionSuccess();
      ref.invalidate(myWaitlistStatusProvider(walkId));
      ref.invalidate(waitlistCountsProvider(walkId));
    } catch (e) {
      state = WaitlistActionError(t.errors.failedToCancelRsvp(error: e));
    }
  }

  void reset() => state = const WaitlistActionIdle();
}

final waitlistActionProvider =
    NotifierProvider.family<WaitlistActionNotifier, WaitlistActionState, String>(
  (walkId) => WaitlistActionNotifier(walkId),
);
