class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final String createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? json['sender_id'] ?? '',
      receiverId: json['receiverId'] ?? json['receiver_id'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }
}

class Conversation {
  final String id;
  final String matchId;
  final String user1Id;
  final String user2Id;
  final ConversationUser? otherUser;
  final Message? lastMessage;
  final int unreadCount;
  final String createdAt;

  Conversation({
    required this.id,
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      matchId: json['matchId'] ?? json['match_id'] ?? '',
      user1Id: json['user1Id'] ?? json['user1_id'] ?? '',
      user2Id: json['user2Id'] ?? json['user2_id'] ?? '',
      otherUser: json['otherUser'] != null ? ConversationUser.fromJson(json['otherUser']) : null,
      lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage']) : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }
}

class ConversationUser {
  final String id;
  final String name;
  final List<String> photos;

  ConversationUser({
    required this.id,
    required this.name,
    this.photos = const [],
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}
