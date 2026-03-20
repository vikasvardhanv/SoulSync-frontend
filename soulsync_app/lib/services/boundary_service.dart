import 'api_client.dart';
import '../config/api_config.dart';

class BoundaryService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getBoundaries() async {
    final response = await _dio.get(ApiConfig.userBoundaries);
    return response.data;
  }

  Future<Map<String, dynamic>> updateBoundaries({
    required List<String> dealBreakers,
    required List<String> mustHaves,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    String? preferredGender,
  }) async {
    final response = await _dio.put(
      ApiConfig.userBoundaries,
      data: {
        'dealBreakers': dealBreakers,
        'mustHaves': mustHaves,
        'minAge': minAge,
        'maxAge': maxAge,
        'maxDistance': maxDistance,
        'preferredGender': preferredGender,
      },
    );
    return response.data;
  }
}
