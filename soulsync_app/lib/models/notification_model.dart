class NotificationModel {
  final String id;
  final String userId;
  final String type; // match_request, match_accepted, match_rejected, message
  final String? fromUserId;
  final String? matchId;
  final String message;
  final bool read;
  final String createdAt;
  final NotificationSender? fromUser;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.fromUserId,
    this.matchId,
    required this.message,
    this.read = false,
    required this.createdAt,
    this.fromUser,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      type: json['type'] ?? '',
      fromUserId: json['fromUserId'] ?? json['from_user_id'],
      matchId: json['matchId'] ?? json['match_id'],
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      fromUser: json['fromUser'] != null ? NotificationSender.fromJson(json['fromUser']) : null,
    );
  }
}

class NotificationSender {
  final String id;
  final String name;
  final List<String> photos;

  NotificationSender({
    required this.id,
    required this.name,
    this.photos = const [],
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}
