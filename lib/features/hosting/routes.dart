import 'package:go_router/go_router.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'presentation/create_event_screen.dart';
import 'presentation/location_picker_screen.dart';
import 'presentation/my_events_screen.dart';
import 'presentation/manage_attendees_screen.dart';
import 'presentation/host_responsibility_screen.dart';

List<RouteBase> hostingRoutes = [
  GoRoute(
    path: '/hosting/create',
    name: 'createEvent',
    builder: (context, state) => const CreateEventScreen(),
  ),
  GoRoute(
    path: '/hosting/edit',
    name: 'editEvent',
    builder: (context, state) {
      final event = state.extra as DogEvent?;
      if (event == null) return const CreateEventScreen();
      return CreateEventScreen(existingEvent: event);
    },
  ),
  GoRoute(
    path: '/hosting/location-picker',
    name: 'locationPicker',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>?;
      return LocationPickerScreen(
        initialLatitude: (args?['lat'] as num?)?.toDouble() ?? 0,
        initialLongitude: (args?['lng'] as num?)?.toDouble() ?? 0,
        initialLocationName: args?['name'] as String?,
      );
    },
  ),
  GoRoute(
    path: '/hosting/my-events',
    name: 'myEvents',
    builder: (context, state) => const MyEventsScreen(),
  ),
  GoRoute(
    path: '/hosting/manage-attendees',
    name: 'manageAttendees',
    builder: (context, state) {
      final event = state.extra as DogEvent?;
      if (event == null) return const MyEventsScreen();
      return ManageAttendeesScreen(event: event);
    },
  ),
  GoRoute(
    path: '/hosting/responsibility',
    name: 'hostResponsibility',
    builder: (context, state) => const HostResponsibilityScreen(),
  ),
];
