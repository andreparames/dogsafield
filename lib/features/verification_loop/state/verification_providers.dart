import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(Supabase.instance.client);
});

sealed class RollCallActionState {
  const RollCallActionState();
}

class RollCallActionIdle extends RollCallActionState {
  const RollCallActionIdle();
}

class RollCallActionLoading extends RollCallActionState {
  const RollCallActionLoading();
}

class RollCallActionSuccess extends RollCallActionState {
  const RollCallActionSuccess();
}

class RollCallActionError extends RollCallActionState {
  final String message;
  const RollCallActionError(this.message);
}

class RollCallActionNotifier extends StateNotifier<RollCallActionState> {
  final Ref _ref;
  final String _eventId;

  RollCallActionNotifier(this._ref, this._eventId)
      : super(const RollCallActionIdle());

  Future<void> submit(List<String> observedIds) async {
    if (state is RollCallActionLoading) return;
    state = const RollCallActionLoading();
    try {
      final repo = _ref.read(verificationRepositoryProvider);
      await repo.submitRollCallEntries(_eventId, observedIds);
      _ref.invalidate(myRollCallEntriesProvider(_eventId));
      state = const RollCallActionSuccess();
    } catch (e) {
      state = RollCallActionError('Failed to submit roll call: $e');
    }
  }

  void reset() => state = const RollCallActionIdle();
}

final rollCallActionProvider =
    StateNotifierProvider.family<RollCallActionNotifier, RollCallActionState, String>(
  (ref, eventId) => RollCallActionNotifier(ref, eventId),
);

final myRollCallEntriesProvider =
    FutureProvider.family.autoDispose<Set<String>, String>((ref, eventId) async {
  final repo = ref.watch(verificationRepositoryProvider);
  final rows = await repo.fetchMyEntries(eventId);
  return rows.map((r) => r['observed_id'] as String).toSet();
});

final matchResultsProvider =
    FutureProvider.family.autoDispose<Map<String, Set<String>>, String>(
  (ref, eventId) async {
    final repo = ref.watch(verificationRepositoryProvider);
    return repo.resolveMatches(eventId);
  },
);

class MatchViewData {
  final Set<String> mutualMatchIds;
  final Set<String> pendingOutgoingIds;
  final Set<String> pendingIncomingIds;

  const MatchViewData({
    required this.mutualMatchIds,
    required this.pendingOutgoingIds,
    required this.pendingIncomingIds,
  });
}

final matchViewDataProvider =
    FutureProvider.family.autoDispose<MatchViewData, String>((ref, eventId) async {
  final repo = ref.watch(verificationRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final allEntries = await repo.fetchAllEntries(eventId);
  final matches = await repo.resolveMatches(eventId);

  final myConfirmedIds = allEntries
      .where((e) => e['observer_id'] as String == user.id)
      .map((e) => e['observed_id'] as String)
      .toSet();

  final confirmedMeIds = allEntries
      .where((e) => e['observed_id'] as String == user.id)
      .map((e) => e['observer_id'] as String)
      .toSet();

  final myMatches = matches[user.id] ?? <String>{};

  return MatchViewData(
    mutualMatchIds: myMatches,
    pendingOutgoingIds: myConfirmedIds.difference(myMatches),
    pendingIncomingIds: confirmedMeIds.difference(myMatches),
  );
});

sealed class PackmateSyncState {
  const PackmateSyncState();
}

class PackmateSyncIdle extends PackmateSyncState {
  const PackmateSyncIdle();
}

class PackmateSyncing extends PackmateSyncState {
  const PackmateSyncing();
}

class PackmateSyncDone extends PackmateSyncState {
  final int failedCount;
  const PackmateSyncDone(this.failedCount);
}

class PackmateSyncError extends PackmateSyncState {
  final String message;
  const PackmateSyncError(this.message);
}

class PackmateSyncNotifier extends StateNotifier<PackmateSyncState> {
  final Ref _ref;
  final String _eventId;

  PackmateSyncNotifier(this._ref, this._eventId)
      : super(const PackmateSyncIdle());

  Future<void> sync() async {
    if (state is PackmateSyncing) return;
    state = const PackmateSyncing();
    try {
      final repo = _ref.read(verificationRepositoryProvider);
      final result = await repo.resolveAndSaveMatches(_eventId);
      _ref.invalidate(matchViewDataProvider(_eventId));
      state = PackmateSyncDone(result.failedCount);
    } catch (e) {
      state = PackmateSyncError('Failed to sync connections: $e');
    }
  }

  void reset() => state = const PackmateSyncIdle();
}

final packmateSyncProvider =
    StateNotifierProvider.family<PackmateSyncNotifier, PackmateSyncState, String>(
  (ref, eventId) => PackmateSyncNotifier(ref, eventId),
);
