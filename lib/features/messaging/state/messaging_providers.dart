import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../onboarding/state/auth_provider.dart';
import '../data/conversation.dart';
import '../data/message.dart';
import '../data/messaging_repository.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(Supabase.instance.client);
});

final conversationsStreamProvider = StreamProvider<List<Conversation>>((ref) {
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.streamConversations();
});

final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.streamMessages(conversationId);
});

final unreadCountProvider = Provider<int>((ref) {
  final conversationsAsync = ref.watch(conversationsStreamProvider);
  final userId = ref.read(authServiceProvider).currentUser?.id;
  if (userId == null) return 0;
  return conversationsAsync.whenOrNull<int>(
    data: (conversations) => conversations.fold<int>(0, (sum, c) => sum + c.unreadCount),
  ) ?? 0;
});

sealed class SendActionState {
  const SendActionState();
}

class SendActionIdle extends SendActionState {
  const SendActionIdle();
}

class SendActionLoading extends SendActionState {
  const SendActionLoading();
}

class SendActionSuccess extends SendActionState {
  const SendActionSuccess();
}

class SendActionError extends SendActionState {
  final String message;
  const SendActionError(this.message);
}

class SendActionNotifier extends Notifier<SendActionState> {
  @override
  SendActionState build() => const SendActionIdle();

  Future<void> send(String conversationId, String content) async {
    if (state is SendActionLoading) return;
    state = const SendActionLoading();
    try {
      final repo = ref.read(messagingRepositoryProvider);
      await repo.sendMessage(conversationId, content);
      state = const SendActionSuccess();
    } catch (e) {
      state = SendActionError(t.messaging.failedToSend);
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      final repo = ref.read(messagingRepositoryProvider);
      await repo.markAsRead(conversationId);
    } catch (e) {
      debugPrint('SendActionNotifier.markAsRead($conversationId): $e');
    }
  }

  void reset() => state = const SendActionIdle();
}

final sendActionProvider =
    NotifierProvider<SendActionNotifier, SendActionState>(
        SendActionNotifier.new);

class StartChatNotifier extends Notifier<AsyncValue<Conversation?>> {
  @override
  AsyncValue<Conversation?> build() => const AsyncData(null);

  Future<void> startChat(String targetUserId) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(messagingRepositoryProvider);
      final canMessage = await repo.canMessageUser(targetUserId);
      if (!canMessage) {
        state = const AsyncData(null);
        throw Exception(t.messaging.cannotMessage);
      }
      final conversation = await repo.getOrCreateConversation(targetUserId);
      state = AsyncData(conversation);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void reset() => state = const AsyncData(null);
}

final startChatProvider =
    NotifierProvider<StartChatNotifier, AsyncValue<Conversation?>>(
        StartChatNotifier.new);
