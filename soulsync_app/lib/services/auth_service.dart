import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String lookingFor,
    String? bio,
    String? location,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    List<String>? interests,
    int? minAge,
    int? maxAge,
  }) async {
    final response = await _dio.post(ApiConfig.register, data: {
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'gender': gender,
      'lookingFor': lookingFor,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (interests != null) 'interests': interests,
      if (minAge != null) 'minAge': minAge,
      if (maxAge != null) 'maxAge': maxAge,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });

    if (response.data['success'] == true) {
      final tokens = response.data['data']['tokens'];
      if (tokens != null) {
        await StorageService.saveTokens(
          accessToken: tokens['accessToken'] ?? '',
          refreshToken: tokens['refreshToken'] ?? '',
        );
      }
    }
    return response.data;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post(ApiConfig.logout, data: {
          'refreshToken': refreshToken,
        });
      }
    } catch (_) {
      // Continue logout even if API fails
    } finally {
      await StorageService.clearTokens();
    }
  }

  Future<User?> getMe() async {
    try {
      final response = await _dio.get(ApiConfig.getMe);
      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']['user']);
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post(ApiConfig.forgotPassword, data: {
      'email': email,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String userId,
    required String newPassword,
  }) async {
    final response = await _dio.post(ApiConfig.resetPassword, data: {
      'token': token,
      'userId': userId,
      'newPassword': newPassword,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.put(ApiConfig.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    final response = await _dio.put(ApiConfig.userProfile, data: updates);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    final response = await _dio.delete(ApiConfig.deleteAccount, data: {
      'password': password,
      'confirmation': confirmation,
    });
    return response.data;
  }
}
