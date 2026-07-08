import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/connection_providers.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(blockedUsersProvider);
    final theme = Theme.of(context);

    ref.listen<ConnectionActionState>(connectionActionProvider, (prev, next) {
      if (next is ConnectionActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      } else if (next is ConnectionActionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User unblocked')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: blockedAsync.when(
        data: (blocked) {
          if (blocked.isEmpty) {
            return Center(
              child: Text(
                'No blocked users',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: blocked.length,
            itemBuilder: (context, index) {
              final connection = blocked[index];
              final profile = connection.blockedUserProfile;
              final tierLabel = switch (connection.blockTier) {
                1 => 'Blocked',
                2 => 'Blocked & Hidden',
                3 => 'Reported',
                _ => 'Blocked',
              };

              return ListTile(
                leading: CircleAvatar(
                  child: profile?.photoUrl != null
                      ? Image.network(
                          profile!.photoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24),
                        )
                      : const Icon(Icons.person, size: 24),
                ),
                title: Text(profile?.displayName ?? 'Unknown'),
                subtitle: Text(tierLabel),
                trailing: TextButton(
                  onPressed: () => ref.read(connectionActionProvider.notifier).unblockUser(connection.userIdB),
                  child: const Text('Unblock'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Could not load blocked users', style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(blockedUsersProvider),
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