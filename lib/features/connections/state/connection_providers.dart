import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/connection_status.dart';
import '../../../shared/models/user_profile.dart';
import '../data/connection_repository.dart';

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository(Supabase.instance.client);
});

final blockedUsersProvider = FutureProvider<List<ConnectionStatus>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final rows = await repo.fetchBlockedUsers();

  final results = <ConnectionStatus>[];
  for (final row in rows) {
    final profileData = row['profiles'] as Map<String, dynamic>?;
    UserProfile? profile;
    if (profileData != null) {
      profile = UserProfile(
        id: profileData['id'] as String,
        email: profileData['email'] as String,
        displayName: profileData['display_name'] as String?,
        photoUrl: profileData['photo_url'] as String?,
        isVerified: profileData['is_verified'] as bool? ?? false,
        trialRsvpsUsed: profileData['trial_rsvps_used'] as int? ?? 0,
        isFoundingPack: profileData['is_founding_pack'] as bool? ?? false,
        isSuspended: profileData['is_suspended'] as bool? ?? false,
        hasSeenFieldIntro: profileData['has_seen_field_intro'] as bool? ?? false,
        hasSeenHostIntro: profileData['has_seen_host_intro'] as bool? ?? false,
        treatPolicy: profileData['treat_policy'] != null
            ? TreatPolicy.values.where((p) => p.name == profileData['treat_policy']).firstOrNull
            : null,
      );
    }
    results.add(ConnectionStatus(
      userIdA: row['user_id_a'] as String,
      userIdB: row['user_id_b'] as String,
      arePackmates: row['are_packmates'] as bool? ?? false,
      blockTier: row['block_tier'] as int? ?? 0,
      reportReason: row['report_reason'] as String?,
      blockedUserProfile: profile,
    ));
  }
  return results;
});

sealed class ConnectionActionState {
  const ConnectionActionState();
}

class ConnectionActionIdle extends ConnectionActionState {
  const ConnectionActionIdle();
}

class ConnectionActionLoading extends ConnectionActionState {
  const ConnectionActionLoading();
}

class ConnectionActionSuccess extends ConnectionActionState {
  const ConnectionActionSuccess();
}

class ConnectionActionError extends ConnectionActionState {
  final String message;
  const ConnectionActionError(this.message);
}

class ConnectionActionNotifier extends StateNotifier<ConnectionActionState> {
  final Ref _ref;

  ConnectionActionNotifier(this._ref) : super(const ConnectionActionIdle());

  Future<void> blockUser(String targetUserId) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = _ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 1);
      _ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      state = const ConnectionActionError('Failed to block user. Please try again.');
    }
  }

  Future<void> blockAndHide(String targetUserId) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = _ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 2);
      _ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      state = const ConnectionActionError('Failed to block and hide user. Please try again.');
    }
  }

  Future<void> blockHideAndReport(String targetUserId, String reason) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = _ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 3, reportReason: reason);
      _ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      state = const ConnectionActionError('Failed to report user. Please try again.');
    }
  }

  Future<void> unblockUser(String targetUserId) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = _ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 0);
      _ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      state = const ConnectionActionError('Failed to unblock user. Please try again.');
    }
  }

  void reset() => state = const ConnectionActionIdle();
}

final blockedUserIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final rows = await repo.fetchBlockedUsers();
  return rows.map((r) => r['user_id_b'] as String).toSet();
});

final blockerIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final rows = await repo.fetchBlockers();
  return rows.map((r) => r['user_id_a'] as String).toSet();
});

final connectionActionProvider =
    StateNotifierProvider<ConnectionActionNotifier, ConnectionActionState>((ref) {
  return ConnectionActionNotifier(ref);
});