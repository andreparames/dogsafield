import 'package:go_router/go_router.dart';
import 'presentation/field_map_screen.dart';

List<RouteBase> fieldMapRoutes = [
  GoRoute(
    path: '/map',
    builder: (context, state) => const FieldMapScreen(),
  ),
];
