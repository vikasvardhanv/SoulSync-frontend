import '../config/api_config.dart';

class Match {
  final String id;
  final String userInitiatorId;
  final String userReceiverId;
  final double? compatibilityScore;
  final String status; // pending, accepted, rejected
  final String createdAt;
  final String updatedAt;
  final MatchUser? userInitiator;
  final MatchUser? userReceiver;

  Match({
    required this.id,
    required this.userInitiatorId,
    required this.userReceiverId,
    this.compatibilityScore,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    this.userInitiator,
    this.userReceiver,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? '',
      userInitiatorId: json['userInitiatorId'] ?? json['user_initiator_id'] ?? '',
      userReceiverId: json['userReceiverId'] ?? json['user_receiver_id'] ?? '',
      compatibilityScore: json['compatibilityScore']?.toDouble() ?? json['compatibility_score']?.toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
      userInitiator: json['userInitiator'] != null ? MatchUser.fromJson(json['userInitiator']) : null,
      userReceiver: json['userReceiver'] != null ? MatchUser.fromJson(json['userReceiver']) : null,
    );
  }
}

class MatchUser {
  final String id;
  final String name;
  final int? age;
  final String? bio;
  final String? location;
  final List<String> photos;
  final List<String> interests;

  MatchUser({
    required this.id,
    required this.name,
    this.age,
    this.bio,
    this.location,
    this.photos = const [],
    this.interests = const [],
  });

  factory MatchUser.fromJson(Map<String, dynamic> json) {
    return MatchUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'],
      bio: json['bio'],
      location: json['location'],
      photos: (json['photos'] as List? ?? []).map((p) {
        final s = p.toString();
        if (s.startsWith('http') || s.startsWith('data:')) return s;
        return ApiConfig.renderImage(s);
      }).toList(),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}
