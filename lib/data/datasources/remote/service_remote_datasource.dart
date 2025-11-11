import '../../models/service_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getBarberServices(String barberId);
  Future<ServiceModel> getServiceById(String id);
  Future<ServiceModel> createService(String barberId, {
    required String name,
    required double price,
    String? description,
    String? includes,
  });
  Future<List<ServiceModel>> createMultipleServices(String barberId, List<Map<String, dynamic>> services);
  Future<ServiceModel> updateService(String id, {
    String? name,
    double? price,
    String? description,
    String? includes,
  });
  Future<void> deleteService(String id);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final Dio dio;

  ServiceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ServiceModel>> getBarberServices(String barberId) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/services/barber/$barberId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener servicios',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBarberServices error: ${e.message}', error: e);
      throw Exception('Error al obtener servicios: ${e.message}');
    }
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/services/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ServiceModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener servicio',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetServiceById error: ${e.message}', error: e);
      throw Exception('Error al obtener servicio: ${e.message}');
    }
  }

  @override
  Future<ServiceModel> createService(String barberId, {
    required String name,
    required double price,
    String? description,
    String? includes,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/services/barber/$barberId',
        data: {
          'name': name,
          'price': price,
          if (description != null) 'description': description,
          if (includes != null) 'includes': includes,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ServiceModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear servicio',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateService error: ${e.message}', error: e);
      throw Exception('Error al crear servicio: ${e.message}');
    }
  }

  @override
  Future<List<ServiceModel>> createMultipleServices(String barberId, List<Map<String, dynamic>> services) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/services/barber/$barberId/multiple',
        data: {
          'services': services,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear servicios',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateMultipleServices error: ${e.message}', error: e);
      throw Exception('Error al crear servicios: ${e.message}');
    }
  }

  @override
  Future<ServiceModel> updateService(String id, {
    String? name,
    double? price,
    String? description,
    String? includes,
  }) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/services/$id',
        data: {
          if (name != null) 'name': name,
          if (price != null) 'price': price,
          if (description != null) 'description': description,
          if (includes != null) 'includes': includes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ServiceModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar servicio',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateService error: ${e.message}', error: e);
      throw Exception('Error al actualizar servicio: ${e.message}');
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await dio.delete('${AppConstants.baseUrl}/api/services/$id');
    } on DioException catch (e) {
      appLogger.e('DeleteService error: ${e.message}', error: e);
      throw Exception('Error al eliminar servicio: ${e.message}');
    }
  }
}
