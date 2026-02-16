import '../config/api_config.dart';

class User {
  final String id;
  final String email;
  final String name;
  final int? age;
  final String? bio;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? gender;
  final String? lookingFor;
  final List<String> interests;
  final List<String> photos;
  final bool isVerified;
  final bool isActive;
  final int? personalityScore;
  final int? questionsAnswered;
  final bool? hasPremium;
  final SubscriptionInfo? subscription;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.age,
    this.bio,
    this.location,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.gender,
    this.lookingFor,
    this.interests = const [],
    this.photos = const [],
    this.isVerified = false,
    this.isActive = true,
    this.personalityScore,
    this.questionsAnswered,
    this.hasPremium,
    this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      age: json['age'],
      bio: json['bio'],
      location: json['location'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      gender: json['gender'],
      lookingFor: json['lookingFor'],
      interests: List<String>.from(json['interests'] ?? []),
      photos: (json['photos'] as List? ?? []).map((p) {
        final s = p.toString();
        // If it's already a URL, return it. Otherwise construct render URL.
        if (s.startsWith('http') || s.startsWith('data:')) return s;
        return ApiConfig.renderImage(s);
      }).toList(),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      personalityScore: json['personalityScore'],
      questionsAnswered: json['questionsAnswered'],
      hasPremium: json['hasPremium'],
      subscription: json['subscription'] != null
          ? SubscriptionInfo.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (age != null) 'age': age,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gender != null) 'gender': gender,
      if (lookingFor != null) 'lookingFor': lookingFor,
      'interests': interests,
      'photos': photos,
    };
  }

  User copyWith({
    String? name,
    int? age,
    String? bio,
    String? location,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    String? gender,
    String? lookingFor,
    List<String>? interests,
    List<String>? photos,
    bool? isVerified,
    int? personalityScore,
    int? questionsAnswered,
    bool? hasPremium,
    SubscriptionInfo? subscription,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive,
      personalityScore: personalityScore ?? this.personalityScore,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      hasPremium: hasPremium ?? this.hasPremium,
      subscription: subscription ?? this.subscription,
    );
  }
}

class SubscriptionInfo {
  final String plan;
  final String status;
  final String expiresAt;

  SubscriptionInfo({
    required this.plan,
    required this.status,
    required this.expiresAt,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: json['plan'] ?? 'free',
      status: json['status'] ?? 'active',
      expiresAt: json['expiresAt'] ?? '',
    );
  }
}
