import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/features/messaging/data/conversation.dart';
import 'package:dogsafield/features/messaging/data/message.dart';
import 'package:dogsafield/features/messaging/state/messaging_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import '../../helpers/test_utils.dart';

final _overrides = <dynamic>[
  authServiceProvider.overrideWithValue(fakeAuthService),
  authStateProvider.overrideWith((ref) => Stream.empty()),
];

void main() {
  group('SendActionNotifier', () {
    test('send transitions through states on success', () async {
      final repo = FakeMessagingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(sendActionProvider.notifier);
      expect(container.read(sendActionProvider), isA<SendActionIdle>());

      notifier.send('conv-1', 'Hello!');
      expect(container.read(sendActionProvider), isA<SendActionLoading>());

      await Future<void>.delayed(Duration.zero);
      expect(container.read(sendActionProvider), isA<SendActionSuccess>());
      expect(repo.sendMessageCallCount, 1);
      expect(repo.lastSentConversationId, 'conv-1');
      expect(repo.lastSentContent, 'Hello!');
    });

    test('send transitions to error on failure', () async {
      final repo = FakeMessagingRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(sendActionProvider.notifier);
      notifier.send('conv-1', 'Hello!');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sendActionProvider);
      expect(state, isA<SendActionError>());
      expect((state as SendActionError).message, contains('Failed to send'));
    });

    test('re-entrancy guard prevents concurrent sends', () async {
      final repo = FakeMessagingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(sendActionProvider.notifier);
      notifier.send('conv-1', 'msg1');
      notifier.send('conv-1', 'msg2');

      await Future<void>.delayed(Duration.zero);
      expect(repo.sendMessageCallCount, 1);
    });

    test('reset returns to idle', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(FakeMessagingRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(sendActionProvider.notifier);
      notifier.reset();
      expect(container.read(sendActionProvider), isA<SendActionIdle>());
    });

    test('markAsRead increments call count', () async {
      final repo = FakeMessagingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(sendActionProvider.notifier);
      await notifier.markAsRead('conv-1');
      expect(repo.markAsReadCallCount, 1);
    });
  });

  group('StartChatNotifier', () {
    test('startChat creates conversation on success', () async {
      final repo = FakeMessagingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(startChatProvider.notifier);
      expect(container.read(startChatProvider).value, isNull);

      await notifier.startChat('other-user');

      final state = container.read(startChatProvider);
      expect(state.value, isNotNull);
      expect(state.value!.otherUserId, 'other-user');
    });

    test('startChat fails when cannot message user', () async {
      final repo = FakeMessagingRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(startChatProvider.notifier);
      await notifier.startChat('other-user');

      expect(container.read(startChatProvider).hasError, isTrue);
    });
  });

  group('conversationsStreamProvider', () {
    test('returns conversations from provider', () async {
      final repo = FakeMessagingRepository();
      repo.conversations = [
        Conversation(
          id: 'conv-1',
          otherUserId: 'user-b',
          otherUserName: 'Alice',
          lastMessageAt: DateTime.now(),
          lastMessageContent: 'Hey there!',
          unreadCount: 2,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          ..._overrides,
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(conversationsStreamProvider, (_, __) {});
      await Future<void>.delayed(Duration.zero);

      final result = container.read(conversationsStreamProvider).value;
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.otherUserName, 'Alice');
      expect(result.first.lastMessageContent, 'Hey there!');
      expect(result.first.unreadCount, 2);
      sub.close();
    });
  });

  group('messagesStreamProvider', () {
    test('returns messages for conversation from provider', () async {
      final repo = FakeMessagingRepository();
      repo.messages = [
        Message(
          id: 'msg-1',
          conversationId: 'conv-1',
          senderId: 'user-a',
          content: 'Hello!',
          createdAt: DateTime(2026, 7, 11, 10, 0),
        ),
        Message(
          id: 'msg-2',
          conversationId: 'conv-1',
          senderId: 'user-b',
          content: 'Hi there!',
          createdAt: DateTime(2026, 7, 11, 10, 1),
        ),
        Message(
          id: 'msg-3',
          conversationId: 'conv-2',
          senderId: 'user-c',
          content: 'Wrong conversation',
          createdAt: DateTime(2026, 7, 11, 10, 2),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          ..._overrides,
          messagingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(messagesStreamProvider('conv-1'), (_, __) {});
      await Future<void>.delayed(Duration.zero);

      final result = container.read(messagesStreamProvider('conv-1')).value;
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result.first.content, 'Hello!');
      expect(result.last.content, 'Hi there!');
      expect(result.where((m) => m.conversationId != 'conv-1'), isEmpty);
      sub.close();
    });
  });
}
