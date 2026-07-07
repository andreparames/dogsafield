import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/location_provider.dart';
import '../../../core/services/location_service.dart';
import '../state/field_map_providers.dart';
import 'event_bottom_sheet.dart';
import 'event_marker_icon.dart';

class FieldMapScreen extends ConsumerStatefulWidget {
  const FieldMapScreen({super.key});

  @override
  ConsumerState<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends ConsumerState<FieldMapScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentPositionProvider);
    final eventsAsync = ref.watch(discoveredEventsProvider);
    final showRsvps = ref.watch(rsvpFilterProvider);

    ref.listen(currentPositionProvider, (_, next) {
      next.whenData((position) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      });
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/hosting/create'),
        tooltip: 'Create Event',
        child: const Icon(Icons.add),
      ),
      body: locationAsync.when(
        data: (position) {
          final cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          );

          final markers = <Marker>{};
          markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
            ),
          );

          eventsAsync.when(
            data: (events) {
              for (final event in events) {
                markers.add(
                  Marker(
                    markerId: MarkerId(event.id),
                    position: LatLng(event.latitude, event.longitude),
                    icon: markerIconForType(event.type),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => EventBottomSheet(
                          event: event,
                          showRsvpAction: showRsvps,
                        ),
                      );
                    },
                  ),
                );
              }
            },
            loading: () {},
            error: (error, _) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load events: $error')),
              );
            },
          );

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: cameraPosition,
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: markers,
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Nearby'),
                        icon: Icon(Icons.map),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('My RSVPs'),
                        icon: Icon(Icons.bookmark),
                      ),
                    ],
                    selected: {showRsvps},
                    onSelectionChanged: (selected) {
                      ref.read(rsvpFilterProvider.notifier).state = selected.first;
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to get your location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please grant location permission to see the map.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _retry() async {
    final service = LocationService();
    final permission = await service.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied. Open settings to enable.')),
      );
      await Geolocator.openAppSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required to show the map.')),
      );
      return;
    }

    final enabled = await service.isLocationEnabled();
    if (!enabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Enable them in settings.')),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    ref.invalidate(currentPositionProvider);
  }
}
