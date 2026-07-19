import 'package:go_router/go_router.dart';
import 'presentation/field_map_screen.dart';
import 'presentation/gathering_details_screen.dart';
import 'presentation/pack_walk_detail_screen.dart';

List<RouteBase> fieldMapRoutes = [
  GoRoute(
    path: '/map',
    builder: (context, state) => const FieldMapScreen(),
  ),
  GoRoute(
    path: '/field/gathering/:eventId',
    builder: (context, state) {
      final eventId = state.pathParameters['eventId']!;
      return GatheringDetailsScreen(eventId: eventId);
    },
  ),
  GoRoute(
    path: '/field/pack-walk/:eventId',
    builder: (context, state) {
      final eventId = state.pathParameters['eventId']!;
      return PackWalkDetailScreen(eventId: eventId);
    },
  ),
];
