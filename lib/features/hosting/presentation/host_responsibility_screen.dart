import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../account/state/account_providers.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../onboarding/state/onboarding_state.dart';

class HostResponsibilityScreen extends ConsumerWidget {
  const HostResponsibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Before You Host')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.volunteer_activism, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text('Hosting Responsibility', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Thank you for stepping up to host! A few things to keep in mind:',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _TipCard(
            icon: Icons.access_time,
            title: 'Show up on time',
            description: 'Attendees plan their day around your event. Arrive a few minutes early to get settled.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.message,
            title: 'Communicate changes',
            description: 'If you need to cancel or reschedule, do it as early as possible so attendees can adjust.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.group,
            title: 'Welcome everyone',
            description: 'New members may be nervous. A warm welcome goes a long way toward building the pack.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.pets,
            title: 'Safety first',
            description: 'Keep an eye on all dogs. If a dog seems stressed or reactive, give them space.',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.report,
            title: 'Report issues',
            description: 'Use the feedback button on the map to report any problems or concerns to the team.',
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
                  try {
                    await repo.markHostIntroSeen(user.id);
                  } catch (_) {}
                }
                if (!context.mounted) return;
                final onboardingState = ref.read(onboardingProvider);
                final existing = onboardingState.userProfile;
                if (existing != null) {
                  ref.read(onboardingProvider.notifier).setUserProfile(existing.copyWith(hasSeenHostIntro: true));
                }
                context.go('/hosting/create');
              },
              icon: const Icon(Icons.check),
              label: const Text('I Understand'),
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
