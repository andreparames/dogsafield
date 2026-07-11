import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/location_provider.dart';
import '../../../core/services/location_service.dart';
import '../../onboarding/state/onboarding_state.dart';
import '../state/field_map_providers.dart';
import '../state/feedback_providers.dart';
import '../state/rsvp_providers.dart';
import 'feedback_dialog.dart';
import 'event_bottom_sheet.dart';
import 'event_marker_icon.dart';
import 'package:dogsafield/i18n/strings.g.dart';

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
    final theme = Theme.of(context);
    final locationAsync = ref.watch(currentPositionProvider);
    final events = ref.watch(discoveredEventsProvider);
    final rsvpIdsAsync = ref.watch(myRsvpIdsProvider);
    final showRsvps = ref.watch(rsvpFilterProvider);

    ref.listen(currentPositionProvider, (_, next) {
      next.whenData((position) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      });
    });

    ref.listen(allEventsProvider, (_, next) {
      next.whenOrNull(error: (error, _) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.fieldMap.failedToLoadEvents(error: error))),
        );
      });
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final profile = ref.read(onboardingProvider).userProfile;
          if (profile == null || !profile.hasSeenHostIntro) {
            context.push('/hosting/responsibility');
          } else {
            context.push('/hosting/create');
          }
        },
        tooltip: context.t.fieldMap.createEvent,
        child: const Icon(Icons.add),
      ),
      body: locationAsync.when(
        data: (position) {
          final cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          );

          final markers = <Marker>{};

          final rsvpIds = rsvpIdsAsync.asData?.value ?? {};
          for (final event in events) {
            markers.add(
              Marker(
                markerId: MarkerId(event.id),
                position: LatLng(event.latitude, event.longitude),
                icon: markerIconForType(event.type, isRsvpd: rsvpIds.contains(event.id)),
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

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: cameraPosition,
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: markers,
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16,
                        left: 16,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: IconButton(
                    icon: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    onPressed: () => context.push('/account'),
                    tooltip: context.t.fieldMap.account,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(context.t.fieldMap.nearby),
                        icon: Icon(Icons.map),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(context.t.fieldMap.myPacks),
                        icon: Icon(Icons.bookmark),
                      ),
                    ],
                    selected: {showRsvps},
                    onSelectionChanged: (selected) {
                      ref.read(rsvpFilterProvider.notifier).set(selected.first);
                    },
                  ),
                ),
              ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: Icon(Icons.chat_bubble_outline,
                              color: theme.colorScheme.primary),
                          tooltip: context.t.fieldMap.feedback,
                          onPressed: () => _showFeedbackDialog(context),
                        ),
                      ),
                    ],
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
                    context.t.fieldMap.unableToGetLocation,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t.fieldMap.grantPermission,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.t.common.retry),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => FeedbackDialog(
        onSubmit: (message) => ref.read(feedbackProvider.notifier).submit(message),
      ),
    );
  }

  Future<void> _retry() async {
    final service = LocationService();
    final permission = await service.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.fieldMap.permissionDeniedForever)),
      );
      await Geolocator.openAppSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.fieldMap.permissionDenied)),
      );
      return;
    }

    final enabled = await service.isLocationEnabled();
    if (!enabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.fieldMap.locationDisabled)),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    ref.invalidate(currentPositionProvider);
  }
}
