import 'package:go_router/go_router.dart';
import 'presentation/chat_list_screen.dart';
import 'presentation/direct_message_screen.dart';

List<RouteBase> messagingRoutes = [
  GoRoute(
    path: '/messaging',
    name: 'chatList',
    builder: (context, state) => const ChatListScreen(),
  ),
  GoRoute(
    path: '/messaging/chat/:conversationId',
    name: 'chat',
    builder: (context, state) {
      final conversationId = state.pathParameters['conversationId']!;
      final extra = state.extra as Map<String, String>?;
      final otherUserName = extra?['otherUserName'] ?? '';
      return DirectMessageScreen(
        conversationId: conversationId,
        otherUserName: otherUserName,
      );
    },
  ),
];
