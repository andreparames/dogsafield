import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/features/messaging/data/conversation.dart';
import 'package:dogsafield/features/messaging/data/message.dart';
import 'package:dogsafield/features/messaging/state/messaging_providers.dart';
import 'package:dogsafield/features/messaging/presentation/chat_list_screen.dart';
import 'package:dogsafield/features/messaging/presentation/direct_message_screen.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../helpers/test_utils.dart';

void main() {
  setUp(() {
    fakeAuthService.setAuthenticated(
      value: true,
      user: User(
        id: 'current-user',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  });

  group('ChatListScreen', () {
    testWidgets('shows empty state when no conversations', (tester) async {
      final repo = FakeMessagingRepository()..conversations = [];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuthService),
            authStateProvider.overrideWith((ref) => Stream.empty()),
            messagingRepositoryProvider.overrideWithValue(repo),
          ],
          child: TranslationProvider(
            child: MaterialApp(home: const ChatListScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('shows conversations in list', (tester) async {
      final repo = FakeMessagingRepository()
        ..conversations = [
          Conversation(
            id: 'conv-1',
            otherUserId: 'user-b',
            otherUserName: 'Alice',
            lastMessageAt: DateTime(2026, 7, 11, 10, 0),
            lastMessageContent: 'Hey there!',
            unreadCount: 2,
          ),
          Conversation(
            id: 'conv-2',
            otherUserId: 'user-c',
            otherUserName: 'Bob',
            lastMessageAt: DateTime(2026, 7, 11, 9, 0),
            lastMessageContent: 'See you at the park!',
            unreadCount: 0,
          ),
        ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuthService),
            authStateProvider.overrideWith((ref) => Stream.empty()),
            messagingRepositoryProvider.overrideWithValue(repo),
          ],
          child: TranslationProvider(
            child: MaterialApp(home: const ChatListScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Hey there!'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('See you at the park!'), findsOneWidget);
    });
  });

  group('DirectMessageScreen', () {
    testWidgets('shows empty state when no messages', (tester) async {
      final repo = FakeMessagingRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuthService),
            authStateProvider.overrideWith((ref) => Stream.empty()),
            messagingRepositoryProvider.overrideWithValue(repo),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              home: const DirectMessageScreen(
                conversationId: 'conv-1',
                otherUserName: 'Alice',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send a message to start the conversation!'), findsOneWidget);
    });

    testWidgets('displays messages from conversation', (tester) async {
      final repo = FakeMessagingRepository()
        ..messages = [
          Message(
            id: 'msg-1',
            conversationId: 'conv-1',
            senderId: 'other-user',
            content: 'Hello from Alice!',
            createdAt: DateTime(2026, 7, 11, 10, 0),
          ),
          Message(
            id: 'msg-2',
            conversationId: 'conv-1',
            senderId: 'current-user',
            content: 'Hey there!',
            createdAt: DateTime(2026, 7, 11, 10, 1),
          ),
        ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuthService),
            authStateProvider.overrideWith((ref) => Stream.empty()),
            messagingRepositoryProvider.overrideWithValue(repo),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              home: const DirectMessageScreen(
                conversationId: 'conv-1',
                otherUserName: 'Alice',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello from Alice!'), findsOneWidget);
      expect(find.text('Hey there!'), findsOneWidget);
    });

    testWidgets('shows text input field', (tester) async {
      final repo = FakeMessagingRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuthService),
            authStateProvider.overrideWith((ref) => Stream.empty()),
            messagingRepositoryProvider.overrideWithValue(repo),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              home: const DirectMessageScreen(
                conversationId: 'conv-1',
                otherUserName: 'Alice',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
