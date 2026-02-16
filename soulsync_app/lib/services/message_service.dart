import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/message.dart';
import 'api_client.dart';

class MessageService {
  final Dio _dio = ApiClient().dio;

  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get(ApiConfig.conversations);
    if (response.data['success'] == true) {
      return (response.data['data']['conversations'] as List? ?? [])
          .map((c) => Conversation.fromJson(c))
          .toList();
    }
    return [];
  }

  Future<List<Message>> getConversation(String userId, {int? limit, int? offset}) async {
    final response = await _dio.get(
      ApiConfig.conversation(userId),
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    if (response.data['success'] == true) {
      return (response.data['data']['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<Message?> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final response = await _dio.post(ApiConfig.sendMessage, data: {
      'receiverId': receiverId,
      'content': content,
    });
    if (response.data['success'] == true) {
      return Message.fromJson(response.data['data']['message']);
    }
    return null;
  }

  Future<void> markAsRead(String senderId) async {
    await _dio.put(ApiConfig.markAsRead(senderId));
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConfig.unreadCount);
    if (response.data['success'] == true) {
      return response.data['data']['count'] ?? 0;
    }
    return 0;
  }
}
