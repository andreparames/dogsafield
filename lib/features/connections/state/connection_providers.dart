import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/connection_status.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../../shared/models/user_profile.dart';
import '../data/connection_repository.dart';

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository(Supabase.instance.client);
});

final blockedUsersProvider = FutureProvider<List<ConnectionStatus>>((ref) async {
  try {
    final repo = ref.watch(connectionRepositoryProvider);
    final rows = await repo.fetchBlockedUsers();

    final results = <ConnectionStatus>[];
    for (final row in rows) {
      final profileData = row['profiles'] as Map<String, dynamic>?;
      UserProfile? profile;
      if (profileData != null) {
        profile = UserProfile(
          id: profileData['id'] as String,
          email: '',
          displayName: profileData['display_name'] as String?,
          photoUrl: profileData['photo_url'] as String?,
          isFoundingPack: profileData['is_founding_pack'] as bool? ?? false,
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
  } catch (e) {
    debugPrint('blockedUsersProvider error: $e');
    return [];
  }
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

class ConnectionActionNotifier extends Notifier<ConnectionActionState> {
  @override
  ConnectionActionState build() => const ConnectionActionIdle();

  Future<void> blockUser(String targetUserId) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 1);
      ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      debugPrint('ConnectionActionNotifier.block(): $e');
      state = ConnectionActionError(t.errors.failedToBlock);
    }
  }

  Future<void> blockAndHide(String targetUserId) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 2);
      ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      debugPrint('ConnectionActionNotifier.blockAndHide(): $e');
      state = ConnectionActionError(t.errors.failedToBlockAndHide);
    }
  }

  Future<void> blockHideAndReport(String targetUserId, String reason) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 3, reportReason: reason);
      ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      debugPrint('ConnectionActionNotifier.blockHideAndReport(): $e');
      state = ConnectionActionError(t.errors.failedToReport);
    }
  }

  Future<void> unblockUser(String targetUserId) async {
    if (state is ConnectionActionLoading) return;
    state = const ConnectionActionLoading();
    try {
      final repo = ref.read(connectionRepositoryProvider);
      await repo.setBlockTier(targetUserId, 0);
      ref.invalidate(blockedUsersProvider);
      state = const ConnectionActionSuccess();
    } catch (e) {
      debugPrint('ConnectionActionNotifier.unblockUser(): $e');
      state = ConnectionActionError(t.errors.failedToUnblock);
    }
  }

  void reset() => state = const ConnectionActionIdle();
}

final blockedUserIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final rows = await repo.fetchBlockedUsers();
  return rows.map((r) => r['user_id_b'] as String).toSet();
});

final connectionActionProvider =
    NotifierProvider<ConnectionActionNotifier, ConnectionActionState>(
        ConnectionActionNotifier.new);

final blockerIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final rows = await repo.fetchBlockers();
  return rows.map((r) => r['user_id_a'] as String).toSet();
});

