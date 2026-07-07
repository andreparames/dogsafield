import 'package:go_router/go_router.dart';
import 'presentation/create_event_screen.dart';
import 'presentation/location_picker_screen.dart';

List<RouteBase> hostingRoutes = [
  GoRoute(
    path: '/hosting/create',
    name: 'createEvent',
    builder: (context, state) => const CreateEventScreen(),
  ),
  GoRoute(
    path: '/hosting/location-picker',
    name: 'locationPicker',
    builder: (context, state) {
      final args = state.extra as Map<String, double>?;
      return LocationPickerScreen(
        initialLatitude: args?['lat'] ?? 0,
        initialLongitude: args?['lng'] ?? 0,
      );
    },
  ),
];
