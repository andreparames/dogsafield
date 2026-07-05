import 'package:go_router/go_router.dart';
import 'presentation/welcome_screen.dart';
import 'presentation/photo_upload_screen.dart';
import 'presentation/profile_form_screen.dart';
import 'presentation/icebreaker_screen.dart';
import 'presentation/safety_boundaries_screen.dart';

List<RouteBase> onboardingRoutes = [
  GoRoute(
    path: '/onboarding/welcome',
    name: 'welcome',
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: '/onboarding/photo',
    name: 'photoUpload',
    builder: (context, state) => const PhotoUploadScreen(),
  ),
  GoRoute(
    path: '/onboarding/profile',
    name: 'profileForm',
    builder: (context, state) => const ProfileFormScreen(),
  ),
  GoRoute(
    path: '/onboarding/icebreaker',
    name: 'icebreaker',
    builder: (context, state) => const IcebreakerScreen(),
  ),
  GoRoute(
    path: '/onboarding/safety',
    name: 'safetyBoundaries',
    builder: (context, state) => const SafetyBoundariesScreen(),
  ),
];
