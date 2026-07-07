import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/hosting_repository.dart';

final hostingRepositoryProvider = Provider<HostingRepository>((ref) {
  return HostingRepository(Supabase.instance.client);
});
