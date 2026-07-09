import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/providers.dart';
import '../../connections/state/connection_providers.dart';
import '../data/gathering_detail.dart';
import '../data/gathering_repository.dart';

final gatheringRepositoryProvider = Provider<GatheringRepository>((ref) {
  return GatheringRepository(
    Supabase.instance.client,
    ref.watch(localCacheServiceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

final gatheringDetailProvider =
    FutureProvider.family<GatheringDetail, String>((ref, eventId) async {
  final repo = ref.watch(gatheringRepositoryProvider);
  final detail = await repo.fetchGatheringDetail(eventId);
  final blockedIds = await ref.watch(blockedUserIdsProvider.future).catchError((_) => <String>{});
  final blockerIds = await ref.watch(blockerIdsProvider.future).catchError((_) => <String>{});
  return GatheringDetail(
    event: detail.event,
    host: detail.host,
    hostDog: detail.hostDog,
    attendees: detail.attendees
        .where((a) => !blockedIds.contains(a.profile.id) && !blockerIds.contains(a.profile.id))
        .toList(),
  );
});
