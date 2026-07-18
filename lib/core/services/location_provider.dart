import 'dart:async';
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
  print('[LOCATION] Checking if location is enabled...');
  final enabled = await service.isLocationEnabled();
  if (!enabled) {
    print('[LOCATION] Location services are disabled');
    throw Exception('Location services are disabled');
  }
  print('[LOCATION] Location is enabled, checking permission...');
  var permission = await service.checkPermission();
  print('[LOCATION] Permission: $permission');
  if (permission == LocationPermission.denied) {
    print('[LOCATION] Requesting permission...');
    permission = await service.requestPermission();
    print('[LOCATION] Permission after request: $permission');
  }
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied forever');
  }
  print('[LOCATION] Getting current position with high accuracy...');
  try {
    final pos = await service.getCurrentLocation().timeout(
      const Duration(seconds: 10),
    );
    print('[LOCATION] Got position: ${pos.latitude}, ${pos.longitude}');
    return pos;
  } on TimeoutException {
    print('[LOCATION] High accuracy timed out, trying last known...');
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      print('[LOCATION] Got last known: ${last.latitude}, ${last.longitude}');
      return last;
    }
    print('[LOCATION] No last known, trying low accuracy...');
    final pos = await service.getCurrentLocation(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );
    print('[LOCATION] Got low accuracy: ${pos.latitude}, ${pos.longitude}');
    return pos;
  }
});
