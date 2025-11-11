import '../../models/barber_media_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

abstract class BarberMediaRemoteDataSource {
  Future<List<BarberMediaModel>> getBarberMedia(String barberId);
  Future<BarberMediaModel> createMedia(String barberId, {
    required String type,
    required String url,
    String? thumbnail,
    String? caption,
  });
  Future<List<BarberMediaModel>> createMultipleMedia(String barberId, List<Map<String, dynamic>> media);
  Future<BarberMediaModel> updateMedia(String id, {
    String? caption,
    String? thumbnail,
  });
  Future<void> deleteMedia(String id);
  Future<BarberMediaModel> getMediaById(String id);
}

class BarberMediaRemoteDataSourceImpl implements BarberMediaRemoteDataSource {
  final Dio dio;

  BarberMediaRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BarberMediaModel>> getBarberMedia(String barberId) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/barber-media/barber/$barberId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberMediaModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener medios',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBarberMedia error: ${e.message}', error: e);
      throw Exception('Error al obtener medios: ${e.message}');
    }
  }

  @override
  Future<BarberMediaModel> createMedia(String barberId, {
    required String type,
    required String url,
    String? thumbnail,
    String? caption,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/barber-media/barber/$barberId',
        data: {
          'type': type,
          'url': url,
          if (thumbnail != null) 'thumbnail': thumbnail,
          if (caption != null) 'caption': caption,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberMediaModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear medio',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateMedia error: ${e.message}', error: e);
      throw Exception('Error al crear medio: ${e.message}');
    }
  }

  @override
  Future<List<BarberMediaModel>> createMultipleMedia(String barberId, List<Map<String, dynamic>> media) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/barber-media/barber/$barberId/multiple',
        data: {
          'media': media,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberMediaModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear medios',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateMultipleMedia error: ${e.message}', error: e);
      throw Exception('Error al crear medios: ${e.message}');
    }
  }

  @override
  Future<BarberMediaModel> updateMedia(String id, {
    String? caption,
    String? thumbnail,
  }) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/barber-media/$id',
        data: {
          if (caption != null) 'caption': caption,
          if (thumbnail != null) 'thumbnail': thumbnail,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberMediaModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar medio',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateMedia error: ${e.message}', error: e);
      throw Exception('Error al actualizar medio: ${e.message}');
    }
  }

  @override
  Future<void> deleteMedia(String id) async {
    try {
      await dio.delete('${AppConstants.baseUrl}/api/barber-media/$id');
    } on DioException catch (e) {
      appLogger.e('DeleteMedia error: ${e.message}', error: e);
      throw Exception('Error al eliminar medio: ${e.message}');
    }
  }

  @override
  Future<BarberMediaModel> getMediaById(String id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/barber-media/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberMediaModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener medio',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetMediaById error: ${e.message}', error: e);
      throw Exception('Error al obtener medio: ${e.message}');
    }
  }
}
