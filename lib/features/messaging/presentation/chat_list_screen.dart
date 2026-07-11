import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../state/messaging_providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.messaging.title),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      context.t.messaging.empty,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t.messaging.emptyHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final theme = Theme.of(context);

              return ListTile(
                leading: CircleAvatar(
                  child: conversation.otherUserPhoto != null
                      ? ClipOval(
                          child: Image.network(
                            conversation.otherUserPhoto!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 24),
                          ),
                        )
                      : const Icon(Icons.person, size: 24),
                ),
                title: Text(
                  conversation.otherUserName ?? context.t.common.unknown,
                  style: conversation.unreadCount > 0
                      ? theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)
                      : null,
                ),
                subtitle: Text(
                  conversation.lastMessageContent ?? context.t.messaging.noMessages,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: conversation.unreadCount > 0
                      ? theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)
                      : null,
                ),
                trailing: conversation.unreadCount > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '${conversation.unreadCount}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  context.push('/messaging/chat/${conversation.id}');
                },
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
                Text(context.t.messaging.failedToLoad, style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(conversationsStreamProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t.common.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
