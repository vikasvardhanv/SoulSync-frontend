import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/match.dart';
import 'api_client.dart';

class MatchService {
  final Dio _dio = ApiClient().dio;

  Future<List<Match>> getMatches() async {
    try {
      final response = await _dio.get(ApiConfig.matches);
      if (response.data['success'] == true) {
        return (response.data['data']['matches'] as List? ?? [])
            .map((m) => Match.fromJson(m))
            .toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      if (e.response?.statusCode == 401) return [];
    }
    return [];
  }

  Future<Map<String, dynamic>> createMatch({
    required String matchedUserId,
    required double compatibilityScore,
  }) async {
    final response = await _dio.post(ApiConfig.matches, data: {
      'matchedUserId': matchedUserId,
      'compatibilityScore': compatibilityScore,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateMatchStatus({
    required String matchId,
    required String status,
  }) async {
    final response = await _dio.put(
      ApiConfig.updateMatchStatus(matchId),
      data: {'status': status},
    );
    return response.data;
  }

  Future<Match?> getMatchDetails(String matchId) async {
    try {
      final response = await _dio.get(ApiConfig.matchDetails(matchId));
      if (response.data['success'] == true) {
        return Match.fromJson(response.data['data']['match']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      if (e.response?.statusCode == 401) return null;
    }
    return null;
  }

  Future<List<dynamic>> getPotentialMatches({int? limit, int? offset}) async {
    try {
      final response = await _dio.get(ApiConfig.potentialMatches, queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      });
      if (response.data['success'] == true) {
        final matches = response.data['data']['matches'] as List? ?? [];
        return matches.map((m) {
          if (m['photos'] != null) {
            m['photos'] = (m['photos'] as List).map((p) {
               final s = p.toString();
               if (s.startsWith('http') || s.startsWith('data:')) return s;
               return ApiConfig.renderImage(s);
            }).toList();
          }
          return m;
        }).toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      if (e.response?.statusCode == 401) return [];
    }
    return [];
  }

  Future<List<Match>> getPendingMatches() async {
    try {
      final response = await _dio.get(ApiConfig.pendingMatches);
      if (response.data['success'] == true) {
        return (response.data['data']['matches'] as List? ?? [])
            .map((m) => Match.fromJson(m))
            .toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      if (e.response?.statusCode == 401) return [];
    }
    return [];
  }

  Future<List<Match>> getAcceptedMatches() async {
    try {
      final response = await _dio.get(ApiConfig.acceptedMatches);
      if (response.data['success'] == true) {
        return (response.data['data']['matches'] as List? ?? [])
            .map((m) => Match.fromJson(m))
            .toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      if (e.response?.statusCode == 401) return [];
    }
    return [];
  }
}
