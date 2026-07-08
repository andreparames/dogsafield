import 'package:go_router/go_router.dart';
import 'presentation/field_intro_screen.dart';

final infoRoutes = [
  GoRoute(
    path: '/field/intro',
    builder: (context, state) => const FieldIntroScreen(),
  ),
];
