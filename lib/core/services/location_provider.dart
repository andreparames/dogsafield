import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationPermissionProvider = FutureProvider<LocationPermission>((ref) {
  return ref.read(locationServiceProvider).checkPermission();
});

final currentPositionProvider = FutureProvider<Position>((ref) {
  return ref.read(locationServiceProvider).getCurrentLocation();
});
