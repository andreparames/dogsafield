import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/conversation.dart';
import '../data/message.dart';

class MessagingRepository {
  final SupabaseClient _client;

  MessagingRepository(this._client);

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.id;
  }

  Future<List<Conversation>> fetchConversations() async {
    final userId = _currentUserId;

    final rows = await _client.from('conversations')
        .select()
        .or('user_a.eq.$userId,user_b.eq.$userId')
        .order('last_message_at', ascending: false);

    if (rows.isEmpty) return [];

    final otherUserIds = rows.map((r) {
      final a = r['user_a'] as String;
      final b = r['user_b'] as String;
      return a == userId ? b : a;
    }).toList();

    final conversationIds = rows.map((r) => r['id'] as String).toList();

    final profiles = await _client.from('profiles_public')
        .select('id, display_name, photo_url')
        .inFilter('id', otherUserIds);

    final profileMap = {for (final p in profiles) p['id'] as String: p};
    final unreadMap = await _fetchUnreadCounts(conversationIds, userId);

    return rows.map((r) {
      final a = r['user_a'] as String;
      final b = r['user_b'] as String;
      final otherId = a == userId ? b : a;
      final convoId = r['id'] as String;
      final profile = profileMap[otherId];

      return Conversation(
        id: convoId,
        otherUserId: otherId,
        otherUserName: profile?['display_name'] as String?,
        otherUserPhoto: profile?['photo_url'] as String?,
        lastMessageAt: DateTime.parse(r['last_message_at'] as String),
        lastMessageContent: r['last_message_content'] as String?,
        unreadCount: unreadMap[convoId] ?? 0,
      );
    }).toList();
  }

  Stream<List<Message>> streamMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(_rowToMessage).toList());
  }

  Stream<List<Conversation>> streamConversations() {
    final userId = _currentUserId;
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .asyncMap((rows) async {
      if (rows.isEmpty) return [];

      final otherUserIds = rows.map((r) {
        final a = r['user_a'] as String;
        final b = r['user_b'] as String;
        return a == userId ? b : a;
      }).toList();

      final conversationIds = rows.map((r) => r['id'] as String).toList();

      final profiles = await _client.from('profiles_public')
          .select('id, display_name, photo_url')
          .inFilter('id', otherUserIds);

      final profileMap = {for (final p in profiles) p['id'] as String: p};
      final unreadMap = await _fetchUnreadCounts(conversationIds, userId);

      return rows.map((r) {
        final a = r['user_a'] as String;
        final b = r['user_b'] as String;
        final otherId = a == userId ? b : a;
        final convoId = r['id'] as String;
        final profile = profileMap[otherId];

        return Conversation(
          id: convoId,
          otherUserId: otherId,
          otherUserName: profile?['display_name'] as String?,
          otherUserPhoto: profile?['photo_url'] as String?,
          lastMessageAt: DateTime.parse(r['last_message_at'] as String),
          lastMessageContent: r['last_message_content'] as String?,
          unreadCount: unreadMap[convoId] ?? 0,
        );
      }).toList();
    });
  }

  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final userId = _currentUserId;

    final a = userId.compareTo(otherUserId) < 0 ? userId : otherUserId;
    final b = userId.compareTo(otherUserId) < 0 ? otherUserId : userId;

    final existing = await _client.from('conversations')
        .select()
        .eq('user_a', a)
        .eq('user_b', b)
        .maybeSingle();

    if (existing != null) {
      return _buildConversationFromRow(existing, otherUserId);
    }

    try {
      final inserted = await _client.from('conversations')
          .insert({'user_a': a, 'user_b': b})
          .select()
          .single();
      return _buildConversationFromRow(inserted, otherUserId);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        final row = await _client.from('conversations')
            .select()
            .eq('user_a', a)
            .eq('user_b', b)
            .single();
        return _buildConversationFromRow(row, otherUserId);
      }
      rethrow;
    }
  }

  Future<Message> sendMessage(String conversationId, String content) async {
    final userId = _currentUserId;

    final row = await _client.from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': userId,
          'content': content,
        })
        .select()
        .single();

    return _rowToMessage(row);
  }

  Future<void> markAsRead(String conversationId) async {
    final userId = _currentUserId;

    await _client.from('messages')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .isFilter('read_at', null);
  }

  Future<bool> canMessageUser(String targetUserId) async {
    final userId = _currentUserId;

    final connection = await _client.from('connections')
        .select('are_packmates, block_tier')
        .or('and(user_id_a.eq.$userId,user_id_b.eq.$targetUserId),and(user_id_a.eq.$targetUserId,user_id_b.eq.$userId)')
        .maybeSingle();

    if (connection == null) return false;
    if (connection['block_tier'] as int > 0) return false;
    return connection['are_packmates'] as bool;
  }

  Future<Map<String, int>> _fetchUnreadCounts(List<String> conversationIds, String userId) async {
    if (conversationIds.isEmpty) return {};
    final rows = await _client.from('messages')
        .select('conversation_id')
        .inFilter('conversation_id', conversationIds)
        .neq('sender_id', userId)
        .isFilter('read_at', null);
    final map = <String, int>{};
    for (final r in rows) {
      final cid = r['conversation_id'] as String;
      map[cid] = (map[cid] ?? 0) + 1;
    }
    return map;
  }

  Future<Conversation> _buildConversationFromRow(Map<String, dynamic> row, String otherUserId) async {
    final profile = await _client.from('profiles_public')
        .select('id, display_name, photo_url')
        .eq('id', otherUserId)
        .maybeSingle();

    return Conversation(
      id: row['id'] as String,
      otherUserId: otherUserId,
      otherUserName: profile?['display_name'] as String?,
      otherUserPhoto: profile?['photo_url'] as String?,
      lastMessageAt: DateTime.parse(row['last_message_at'] as String),
      lastMessageContent: row['last_message_content'] as String?,
    );
  }

  Message _rowToMessage(Map<String, dynamic> row) {
    return Message(
      id: row['id'] as String,
      conversationId: row['conversation_id'] as String,
      senderId: row['sender_id'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      readAt: row['read_at'] != null ? DateTime.parse(row['read_at'] as String) : null,
    );
  }
}
