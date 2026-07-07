import 'package:go_router/go_router.dart';
import 'presentation/create_event_screen.dart';

List<RouteBase> hostingRoutes = [
  GoRoute(
    path: '/hosting/create',
    name: 'createEvent',
    builder: (context, state) => const CreateEventScreen(),
  ),
];
