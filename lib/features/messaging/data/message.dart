enum MessageType { text, eventEdited, eventLeft, accountSuspended }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final MessageType messageType;
  final Map<String, dynamic>? payload;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.messageType = MessageType.text,
    this.payload,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    DateTime? readAt,
    MessageType? messageType,
    Map<String, dynamic>? payload,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      messageType: messageType ?? this.messageType,
      payload: payload ?? this.payload,
    );
  }
}
