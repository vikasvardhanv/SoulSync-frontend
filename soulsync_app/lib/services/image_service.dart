import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class ImageService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      ApiConfig.uploadImage,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        sendTimeout: const Duration(seconds: 60),
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> uploadMultipleImages(List<String> filePaths) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(path),
      ));
    }
    final response = await _dio.post(
      ApiConfig.uploadMultipleImages,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        sendTimeout: const Duration(seconds: 120),
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deletePhoto(String imageId) async {
    final response = await _dio.delete(ApiConfig.deleteImage, data: {
      'imageId': imageId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> reorderPhotos(List<String> photoUrls) async {
    final response = await _dio.put(ApiConfig.reorderImages, data: {
      'photoUrls': photoUrls,
    });
    return response.data;
  }
}
