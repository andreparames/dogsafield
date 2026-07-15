import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/region.dart';

class RegionRepository {
  final SupabaseClient _client;

  RegionRepository(this._client);

  Future<List<Region>> fetchEnabledRegions() async {
    final response = await _client
        .from('regions')
        .select()
        .eq('is_enabled', true)
        .order('name');

    return response.map((row) => _rowToRegion(row)).toList();
  }

  Region _rowToRegion(Map<String, dynamic> row) {
    return Region(
      id: row['id'] as String,
      name: row['name'] as String,
      centerLatitude: (row['center_lat'] as num?)?.toDouble() ?? 0,
      centerLongitude: (row['center_lng'] as num?)?.toDouble() ?? 0,
      radiusKm: (row['radius_km'] as num).toDouble(),
      isEnabled: row['is_enabled'] as bool? ?? true,
    );
  }
}
