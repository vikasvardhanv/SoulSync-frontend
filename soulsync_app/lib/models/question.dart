class Question {
  final String id;
  final String question;
  final String category; // personality, compatibility, lifestyle, values, communication, relationship
  final String type; // scale, multiple, text
  final List<dynamic>? options;
  final int? minValue;
  final int? maxValue;
  final int weight;
  final String? emoji;
  final bool isActive;

  Question({
    required this.id,
    required this.question,
    required this.category,
    required this.type,
    this.options,
    this.minValue,
    this.maxValue,
    this.weight = 1,
    this.emoji,
    this.isActive = true,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? 'text',
      options: json['options'],
      minValue: json['minValue'] ?? json['min_value'],
      maxValue: json['maxValue'] ?? json['max_value'],
      weight: json['weight'] ?? 1,
      emoji: json['emoji'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }
}

class UserAnswer {
  final String id;
  final String userId;
  final String questionId;
  final String answer;
  final String createdAt;

  UserAnswer({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.answer,
    required this.createdAt,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      questionId: json['questionId'] ?? json['question_id'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }
}
