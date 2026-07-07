import 'package:go_router/go_router.dart';
import 'presentation/account_screen.dart';
import 'presentation/upgrade_screen.dart';

List<RouteBase> accountRoutes = [
  GoRoute(
    path: '/account',
    builder: (context, state) => const AccountScreen(),
  ),
  GoRoute(
    path: '/account/upgrade',
    builder: (context, state) => const UpgradeScreen(),
  ),
];
