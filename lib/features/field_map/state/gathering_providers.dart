import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/providers.dart';
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
  return repo.fetchGatheringDetail(eventId);
});
