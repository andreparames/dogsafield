import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationPermissionProvider = FutureProvider<LocationPermission>((ref) {
  return ref.watch(locationServiceProvider).checkPermission();
});

final currentPositionProvider = FutureProvider<Position>((ref) async {
  final service = ref.watch(locationServiceProvider);
  var permission = await service.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await service.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied forever');
  }
  final enabled = await service.isLocationEnabled();
  if (!enabled) {
    throw Exception('Location services are disabled');
  }
  return service.getCurrentLocation();
});
