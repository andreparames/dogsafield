import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/region.dart';
import '../data/region_repository.dart';

final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  return RegionRepository(Supabase.instance.client);
});

final enabledRegionsProvider = FutureProvider<List<Region>>((ref) async {
  final repo = ref.watch(regionRepositoryProvider);
  return repo.fetchEnabledRegions();
});
