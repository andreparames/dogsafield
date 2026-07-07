import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/account_providers.dart';
import '../../onboarding/state/auth_provider.dart';

class SuspendScreen extends ConsumerWidget {
  const SuspendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(accountDetailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Suspended')),
      body: detailAsync.when(
        data: (_) => _buildContent(context, ref, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(context, ref, theme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_circle_outline, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'Your account is suspended',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your profile is hidden from other users. '
              'You can reactivate your account at any time.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  try {
                    final repo = ref.read(accountRepositoryProvider);
                    await repo.reactivateAccount();
                    if (!context.mounted) return;
                    suspendedNotifier.value = false;
                    ref.invalidate(accountDetailProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account reactivated')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to reactivate: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reactivate Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
