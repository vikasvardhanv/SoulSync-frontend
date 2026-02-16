import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/question.dart';
import 'api_client.dart';

class QuestionService {
  final Dio _dio = ApiClient().dio;

  Future<List<Question>> getQuestions({String? category, int? limit, int? offset}) async {
    final response = await _dio.get(ApiConfig.questions, queryParameters: {
      if (category != null) 'category': category,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    if (response.data['success'] == true) {
      return (response.data['data']['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList();
    }
    return [];
  }

  Future<List<Question>> getRandomQuestions(int count, {String? category}) async {
    final response = await _dio.get(
      ApiConfig.randomQuestions(count),
      queryParameters: {
        if (category != null) 'category': category,
      },
    );
    if (response.data['success'] == true) {
      return (response.data['data']['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> submitAnswer({
    required String questionId,
    required dynamic answer,
  }) async {
    final response = await _dio.post(
      ApiConfig.submitAnswer(questionId),
      data: {'answer': answer},
    );
    return response.data;
  }

  Future<List<UserAnswer>> getMyAnswers() async {
    final response = await _dio.get(ApiConfig.myAnswers);
    if (response.data['success'] == true) {
      return (response.data['data']['answers'] as List? ?? [])
          .map((a) => UserAnswer.fromJson(a))
          .toList();
    }
    return [];
  }

  Future<List<Question>> getQuestionsByCategory(String category) async {
    final response = await _dio.get(ApiConfig.questionsByCategory(category));
    if (response.data['success'] == true) {
      return (response.data['data']['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList();
    }
    return [];
  }
}
