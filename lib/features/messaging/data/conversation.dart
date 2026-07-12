class Conversation {
  final String id;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserPhoto;
  final DateTime lastMessageAt;
  final String? lastMessageContent;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserPhoto,
    required this.lastMessageAt,
    this.lastMessageContent,
    this.unreadCount = 0,
  });

  Conversation copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserPhoto,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserPhoto: otherUserPhoto ?? this.otherUserPhoto,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
