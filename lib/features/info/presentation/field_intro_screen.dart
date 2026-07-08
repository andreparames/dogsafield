import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../account/state/account_providers.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../onboarding/state/onboarding_state.dart';

class FieldIntroScreen extends ConsumerWidget {
  const FieldIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to the Field')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.explore, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text('Explore Dog-Friendly Events', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'The Field map shows everything happening near you. Here\'s how to get started:',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _TipCard(
            icon: Icons.map,
            title: 'Browse the map',
            description: 'Green markers are casual walks, blue are playdates, orange are training sessions. Tap any marker to learn more.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.bookmark,
            title: 'RSVP to join',
            description: 'Tap "Join Pack" to let the host know you\'re coming. You\'ll see your RSVPs in the filter toggle above the map.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.add_location_alt,
            title: 'Host your own',
            description: 'Tap the + button to create a new event. Be sure to read the hosting tips first!',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.chat_bubble_outline,
            title: 'Send feedback',
            description: 'Found a bug or have a suggestion? Tap the chat bubble to share your thoughts with the team.',
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final repo = ref.read(accountRepositoryProvider);
                final auth = ref.read(authServiceProvider);
                final user = auth.currentUser;
                if (user != null) {
                  await repo.markFieldIntroSeen(user.id);
                }
                final onboardingState = ref.read(onboardingProvider);
                final existing = onboardingState.userProfile;
                if (existing != null) {
                  ref.read(onboardingProvider.notifier).setUserProfile(existing.copyWith(hasSeenFieldIntro: true));
                }
                if (!context.mounted) return;
                context.go('/');
              },
              icon: const Icon(Icons.check),
              label: const Text('Got It'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TipCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
