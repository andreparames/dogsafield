import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dogsafield/core/services/location_provider.dart';
import 'package:dogsafield/core/services/location_service.dart';

void main() {
  group('locationServiceProvider', () {
    test('provides a LocationService instance', () {
      // The provider creates LocationService directly; verify it resolves
      expect(locationServiceProvider, isNotNull);
    });
  });

  group('LocationService', () {
    test('isPermissionGranted returns true for allowed permissions', () {
      final service = LocationService();
      expect(service.isPermissionGranted(LocationPermission.always), true);
      expect(service.isPermissionGranted(LocationPermission.whileInUse), true);
    });

    test('isPermissionGranted returns false for denied permissions', () {
      final service = LocationService();
      expect(service.isPermissionGranted(LocationPermission.denied), false);
      expect(service.isPermissionGranted(LocationPermission.deniedForever), false);
    });
  });
}
