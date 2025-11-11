import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'dart:io';

abstract class UploadRemoteDataSource {
  Future<String> uploadFile(File file);
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  final Dio dio;

  UploadRemoteDataSourceImpl(this.dio);

  @override
  Future<String> uploadFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        '${AppConstants.baseUrl}/api/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final url = data['url'] as String;
        // Return relative URL (backend will handle full URL construction when needed)
        return url;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al subir archivo',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UploadFile error: ${e.message}', error: e);
      throw Exception('Error al subir archivo: ${e.message}');
    }
  }
}
