import 'package:go_router/go_router.dart';
import 'presentation/roll_call_screen.dart';
import 'presentation/mutual_match_screen.dart';

List<RouteBase> verificationLoopRoutes = [
  GoRoute(
    path: '/verification/roll-call/:eventId',
    name: 'rollCall',
    builder: (context, state) => RollCallScreen(
      eventId: state.pathParameters['eventId']!,
    ),
  ),
  GoRoute(
    path: '/verification/matches/:eventId',
    name: 'mutualMatches',
    builder: (context, state) => MutualMatchScreen(
      eventId: state.pathParameters['eventId']!,
    ),
  ),
];
