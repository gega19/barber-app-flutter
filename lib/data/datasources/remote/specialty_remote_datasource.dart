import '../../models/specialty_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

abstract class SpecialtyRemoteDataSource {
  Future<List<SpecialtyModel>> getSpecialties();
  Future<SpecialtyModel> getSpecialtyById(String id);
}

class SpecialtyRemoteDataSourceImpl implements SpecialtyRemoteDataSource {
  final Dio dio;

  SpecialtyRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/specialties');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SpecialtyModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener especialidades',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetSpecialties error: ${e.message}', error: e);
      throw Exception('Error al obtener especialidades: ${e.message}');
    }
  }

  @override
  Future<SpecialtyModel> getSpecialtyById(String id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/specialties/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SpecialtyModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener especialidad',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetSpecialtyById error: ${e.message}', error: e);
      throw Exception('Error al obtener especialidad: ${e.message}');
    }
  }
}
