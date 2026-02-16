import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  bool _isRefreshing = false;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await StorageService.getRefreshToken();
        if (refreshToken != null) {
          final response = await Dio(BaseOptions(
            baseUrl: ApiConfig.baseUrl,
          )).post(
            ApiConfig.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (response.data['success'] == true) {
            final tokens = response.data['data']['tokens'];
            await StorageService.saveTokens(
              accessToken: tokens['accessToken'],
              refreshToken: tokens['refreshToken'],
            );

            // Retry original request
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] =
                'Bearer ${tokens['accessToken']}';

            final retryResponse = await dio.fetch(retryOptions);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          }
        }
      } catch (_) {
        await StorageService.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(error);
  }
}
