import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/routes.dart';
import 'features/account/routes.dart';
import 'features/field_map/routes.dart';
import 'features/hosting/routes.dart';
import 'features/verification_loop/routes.dart';
import 'features/connections/routes.dart';
import 'features/messaging/routes.dart';

GoRouter get appRouter => GoRouter(
  initialLocation: '/onboarding/welcome',
  redirect: (context, state) {
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderScreen(label: 'The Field'),
    ),
    ...onboardingRoutes,
    ...accountRoutes,
    ...fieldMapRoutes,
    ...hostingRoutes,
    ...verificationLoopRoutes,
    ...connectionsRoutes,
    ...messagingRoutes,
  ],
);

class PlaceholderScreen extends StatelessWidget {
  final String label;
  const PlaceholderScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dogs Afield — $label')),
      body: Center(child: Text(label, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}
