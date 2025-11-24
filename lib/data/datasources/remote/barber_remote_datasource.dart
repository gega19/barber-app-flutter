import '../../models/barber_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

abstract class BarberRemoteDataSource {
  Future<List<BarberModel>> getBarbers();
  Future<List<BarberModel>> getBestBarbers({int limit = 10});
  Future<BarberModel> getBarberById(String id);
  Future<List<BarberModel>> searchBarbers(String query);
  Future<List<BarberModel>> getBarbersByWorkplaceId(String workplaceId);
  Future<Map<String, dynamic>> updateBarberInfo({
    String? specialty,
    String? specialtyId,
    int? experienceYears,
    String? location,
    double? latitude,
    double? longitude,
    String? instagramUrl,
    String? tiktokUrl,
  });
}

class BarberRemoteDataSourceImpl implements BarberRemoteDataSource {
  final Dio dio;

  BarberRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BarberModel>> getBarbers() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/barbers');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener barberos',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBarbers error: ${e.message}', error: e);
      throw Exception('Error al obtener barberos: ${e.message}');
    }
  }

  @override
  Future<List<BarberModel>> getBestBarbers({int limit = 10}) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barbers/best',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener mejores barberos',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBestBarbers error: ${e.message}', error: e);
      throw Exception('Error al obtener mejores barberos: ${e.message}');
    }
  }

  @override
  Future<BarberModel> getBarberById(String id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/barbers/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener barbero',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBarberById error: ${e.message}', error: e);
      throw Exception('Error al obtener barbero: ${e.message}');
    }
  }

  @override
  Future<List<BarberModel>> searchBarbers(String query) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barbers/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al buscar barberos',
        );
      }
    } on DioException catch (e) {
      appLogger.e('SearchBarbers error: ${e.message}', error: e);
      throw Exception('Error al buscar barberos: ${e.message}');
    }
  }

  @override
  Future<List<BarberModel>> getBarbersByWorkplaceId(String workplaceId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barbers/workplace/$workplaceId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener barberos de la barbería',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBarbersByWorkplaceId error: ${e.message}', error: e);
      throw Exception('Error al obtener barberos de la barbería: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateBarberInfo({
    String? specialty,
    String? specialtyId,
    int? experienceYears,
    String? location,
    double? latitude,
    double? longitude,
    String? instagramUrl,
    String? tiktokUrl,
  }) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/barbers/info',
        data: {
          if (specialty != null) 'specialty': specialty,
          if (specialtyId != null) 'specialtyId': specialtyId,
          if (experienceYears != null) 'experienceYears': experienceYears,
          if (location != null) 'location': location,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (instagramUrl != null) 'instagramUrl': instagramUrl.isEmpty ? null : instagramUrl,
          if (tiktokUrl != null) 'tiktokUrl': tiktokUrl.isEmpty ? null : tiktokUrl,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar información de barbero',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateBarberInfo error: ${e.message}', error: e);
      throw Exception('Error al actualizar información de barbero: ${e.message}');
    }
  }
}

