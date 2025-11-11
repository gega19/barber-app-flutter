import '../../models/workplace_media_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

abstract class WorkplaceMediaRemoteDataSource {
  Future<List<WorkplaceMediaModel>> getWorkplaceMedia(String workplaceId);
}

class WorkplaceMediaRemoteDataSourceImpl implements WorkplaceMediaRemoteDataSource {
  final Dio dio;

  WorkplaceMediaRemoteDataSourceImpl(this.dio);

  @override
  Future<List<WorkplaceMediaModel>> getWorkplaceMedia(String workplaceId) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/workplace-media/workplace/$workplaceId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => WorkplaceMediaModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener medios',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetWorkplaceMedia error: ${e.message}', error: e);
      throw Exception('Error al obtener medios: ${e.message}');
    }
  }
}


