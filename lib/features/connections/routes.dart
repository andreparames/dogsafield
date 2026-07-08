import 'package:go_router/go_router.dart';
import 'presentation/blocked_users_screen.dart';

List<RouteBase> connectionsRoutes = [
  GoRoute(
    path: '/connections/blocked',
    name: 'blockedUsers',
    builder: (context, state) => const BlockedUsersScreen(),
  ),
];
