import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> applyPromo(String code) async {
    final response = await _dio.post(ApiConfig.applyPromo, data: {
      'code': code,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> createSubscription({
    required String plan,
    required String duration,
    required String paymentMethod,
  }) async {
    final response = await _dio.post(ApiConfig.createSubscription, data: {
      'plan': plan,
      'duration': duration,
      'payment_method': paymentMethod,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final response = await _dio.get(ApiConfig.paymentStatus(paymentId));
    return response.data;
  }

  Future<List<dynamic>> getPaymentHistory({int? page, int? limit}) async {
    final response = await _dio.get(ApiConfig.paymentHistory, queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    if (response.data['success'] == true) {
      return response.data['data']['payments'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> getMySubscription() async {
    final response = await _dio.get(ApiConfig.mySubscription);
    return response.data;
  }

  Future<Map<String, dynamic>> checkPremiumStatus() async {
    final response = await _dio.get(ApiConfig.premiumCheck);
    return response.data;
  }

  Future<Map<String, dynamic>> cancelSubscription() async {
    final response = await _dio.put(ApiConfig.cancelSubscription);
    return response.data;
  }
}
