import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../onboarding/state/onboarding_state.dart';
import '../state/account_providers.dart';
import 'founding_pack_badge.dart';
import 'trial_limit_sheet.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/dog.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(accountDetailProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [],
      ),
      body: detailAsync.when(
        data: (detail) => _AccountContent(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Could not load account', style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(accountDetailProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountContent extends StatelessWidget {
  final AccountDetail detail;

  const _AccountContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final profile = detail.profile;
    final dog = detail.dog;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(profile: profile),
          if (dog != null) ...[
            const SizedBox(height: 24),
            _DogCard(dog: dog),
          ],
          const SizedBox(height: 24),
          _TrialSection(profile: profile),
          if (profile.isFoundingPack) ...[
            const SizedBox(height: 24),
            _FoundingSection(profile: profile),
          ],
          if (profile.treatPolicy != null) ...[
            const SizedBox(height: 24),
            _SafetySection(profile: profile),
          ],
          const SizedBox(height: 32),
          _AccountActions(),
          const SizedBox(height: 24),
          _SignOutButton(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          child: profile.photoUrl != null
              ? Image.network(
                  profile.photoUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40),
                )
              : const Icon(Icons.person, size: 40),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName ?? 'Unknown',
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                profile.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DogCard extends StatelessWidget {
  final Dog dog;

  const _DogCard({required this.dog});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                (dog.name.isNotEmpty ? dog.name[0].toUpperCase() : '?'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dog.name, style: theme.textTheme.titleMedium),
                  if (dog.breed != null) ...[
                    const SizedBox(height: 4),
                    Text(dog.breed!, style: theme.textTheme.bodyMedium),
                  ],
                  if (dog.vibe != null) ...[
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(_vibeLabel(dog.vibe!),
                          style: theme.textTheme.labelSmall),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  if (dog.icebreakerAnswer != null && dog.icebreakerAnswer!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '\u201C${dog.icebreakerAnswer}\u201D',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vibeLabel(SocialVibe vibe) {
    return switch (vibe) {
      SocialVibe.loungeLizard => 'Lounge Lizard',
      SocialVibe.zoomieKing => 'Zoomie King',
      SocialVibe.socialLearner => 'Social Learner',
    };
  }
}

class _TrialSection extends StatelessWidget {
  final UserProfile profile;

  const _TrialSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final used = profile.trialRsvpsUsed;
    final maxFree = 3;
    final remaining = (maxFree - used).clamp(0, maxFree);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Trial RSVPs', style: theme.textTheme.titleSmall),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => TrialLimitSheet(used: used, maxFree: maxFree),
                  ),
                  child: Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TrialStat(label: 'Used', value: '$used'),
                const SizedBox(width: 24),
                _TrialStat(label: 'Remaining', value: '$remaining'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: maxFree > 0 ? (used / maxFree).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            if (remaining <= 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/account/upgrade'),
                  icon: const Icon(Icons.star),
                  label: const Text('Upgrade to keep joining'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrialStat extends StatelessWidget {
  final String label;
  final String value;

  const _TrialStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _FoundingSection extends StatelessWidget {
  final UserProfile profile;

  const _FoundingSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const FoundingPackBadge(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'You are a verified Founding Pack member. Enjoy waived fees for events in your founding city.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetySection extends StatelessWidget {
  final UserProfile profile;

  const _SafetySection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Safety Boundaries', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    profile.treatPolicy == TreatPolicy.okToShare
                        ? 'Okay to share treats with my dog'
                        : 'Please ask before feeding my dog',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actionState = ref.watch(accountActionProvider);

    ref.listen<AccountActionState>(accountActionProvider, (prev, next) {
      if (next is AccountActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
      if (next is AccountActionSuccess) {
        ref.read(onboardingProvider.notifier).reset();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danger Zone', style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.error,
        )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: actionState is AccountActionLoading
                ? null
                : () => _showSuspendDialog(context, ref),
            icon: const Icon(Icons.pause_circle_outline),
            label: const Text('Suspend Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: actionState is AccountActionLoading
                ? null
                : () => _showDeleteDialog(context, ref),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuspendDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suspend Account'),
        content: const Text(
          'Your profile will be hidden from other users. '
          'You can reactivate at any time by signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(accountActionProvider.notifier).suspendAccount();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            controller.dispose();
            Navigator.pop(ctx);
          }
        },
        child: AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This permanently removes all your data. '
                'This action cannot be undone.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Type DELETE to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim() != 'DELETE') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Type DELETE to confirm')),
                  );
                  return;
                }
                controller.dispose();
                Navigator.pop(ctx);
                ref.read(accountActionProvider.notifier).deleteAccount();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await ref.read(authServiceProvider).signOut();
            if (!context.mounted) return;
            ref.read(onboardingProvider.notifier).reset();
          } catch (_) {}
        },
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
