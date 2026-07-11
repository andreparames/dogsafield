import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../account/state/account_providers.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../onboarding/state/onboarding_state.dart';

class FieldIntroScreen extends ConsumerWidget {
  const FieldIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.info.fieldIntro.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.explore, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(context.t.info.fieldIntro.heading, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            context.t.info.fieldIntro.intro,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._buildTips(context),
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
                    await repo.markFieldIntroSeen(user.id);
                  } catch (_) {}
                }
                if (!context.mounted) return;
                final onboardingState = ref.read(onboardingProvider);
                final existing = onboardingState.userProfile;
                if (existing != null) {
                  ref.read(onboardingProvider.notifier).setUserProfile(existing.copyWith(hasSeenFieldIntro: true));
                }
                context.go('/');
              },
              icon: const Icon(Icons.check),
              label: Text(context.t.info.fieldIntro.gotIt),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTips(BuildContext context) {
    final tipIcons = [
      Icons.map,
      Icons.bookmark,
      Icons.add_location_alt,
      Icons.chat_bubble_outline,
    ];
    return [
      for (var i = 0; i < context.t.info.fieldIntro.tips.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TipCard(
            icon: tipIcons[i % tipIcons.length],
            title: context.t.info.fieldIntro.tips[i].title,
            description: context.t.info.fieldIntro.tips[i].description,
          ),
        ),
    ];
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
