import '../../models/barber_course_model.dart';
import '../../models/barber_course_media_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

abstract class BarberCourseRemoteDataSource {
  Future<List<BarberCourseModel>> getBarberCourses(String barberId);
  Future<BarberCourseModel> getCourseById(String id);
  Future<BarberCourseModel> createCourse(
    String barberId, {
    required String title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  });
  Future<BarberCourseModel> updateCourse(
    String id, {
    String? title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  });
  Future<void> deleteCourse(String id);

  // Media methods
  Future<List<BarberCourseMediaModel>> getCourseMedia(String courseId);
  Future<BarberCourseMediaModel> getCourseMediaById(String id);
  Future<BarberCourseMediaModel> createCourseMedia(
    String courseId, {
    required String type,
    required String url,
    String? thumbnail,
    String? caption,
  });
  Future<List<BarberCourseMediaModel>> createMultipleCourseMedia(
    String courseId,
    List<Map<String, dynamic>> mediaItems,
  );
  Future<BarberCourseMediaModel> updateCourseMedia(
    String id, {
    String? caption,
    String? thumbnail,
  });
  Future<void> deleteCourseMedia(String id);
}

class BarberCourseRemoteDataSourceImpl implements BarberCourseRemoteDataSource {
  final Dio dio;

  BarberCourseRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BarberCourseModel>> getBarberCourses(String barberId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-courses/barber/$barberId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BarberCourseModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener cursos',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetBarberCourses error: ${e.message}', error: e);
      throw Exception('Error al obtener cursos: ${e.message}');
    }
  }

  @override
  Future<BarberCourseModel> getCourseById(String id) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-courses/course/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberCourseModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener curso',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetCourseById error: ${e.message}', error: e);
      throw Exception('Error al obtener curso: ${e.message}');
    }
  }

  @override
  Future<BarberCourseModel> createCourse(
    String barberId, {
    required String title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/barber-courses/barber/$barberId',
        data: {
          'title': title,
          if (institution != null) 'institution': institution,
          if (description != null) 'description': description,
          if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
          if (duration != null) 'duration': duration,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberCourseModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear curso',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateCourse error: ${e.message}', error: e);
      throw Exception('Error al crear curso: ${e.message}');
    }
  }

  @override
  Future<BarberCourseModel> updateCourse(
    String id, {
    String? title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/barber-courses/course/$id',
        data: {
          if (title != null) 'title': title,
          if (institution != null) 'institution': institution,
          if (description != null) 'description': description,
          if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
          if (duration != null) 'duration': duration,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberCourseModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar curso',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateCourse error: ${e.message}', error: e);
      throw Exception('Error al actualizar curso: ${e.message}');
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/barber-courses/course/$id',
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al eliminar curso',
        );
      }
    } on DioException catch (e) {
      appLogger.e('DeleteCourse error: ${e.message}', error: e);
      throw Exception('Error al eliminar curso: ${e.message}');
    }
  }

  @override
  Future<List<BarberCourseMediaModel>> getCourseMedia(String courseId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-courses/course/$courseId/media',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => BarberCourseMediaModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              response.data['message'] ?? 'Error al obtener media del curso',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetCourseMedia error: ${e.message}', error: e);
      throw Exception('Error al obtener media del curso: ${e.message}');
    }
  }

  @override
  Future<BarberCourseMediaModel> getCourseMediaById(String id) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-courses/media/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberCourseMediaModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener media',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetCourseMediaById error: ${e.message}', error: e);
      throw Exception('Error al obtener media: ${e.message}');
    }
  }

  @override
  Future<BarberCourseMediaModel> createCourseMedia(
    String courseId, {
    required String type,
    required String url,
    String? thumbnail,
    String? caption,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/barber-courses/course/$courseId/media',
        data: {
          'type': type,
          'url': url,
          if (thumbnail != null) 'thumbnail': thumbnail,
          if (caption != null) 'caption': caption,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberCourseMediaModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear media',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateCourseMedia error: ${e.message}', error: e);
      throw Exception('Error al crear media: ${e.message}');
    }
  }

  @override
  Future<List<BarberCourseMediaModel>> createMultipleCourseMedia(
    String courseId,
    List<Map<String, dynamic>> mediaItems,
  ) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/barber-courses/course/$courseId/media/multiple',
        data: {'media': mediaItems},
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        return data
            .map((json) => BarberCourseMediaModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al crear media',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateMultipleCourseMedia error: ${e.message}', error: e);
      throw Exception('Error al crear media: ${e.message}');
    }
  }

  @override
  Future<BarberCourseMediaModel> updateCourseMedia(
    String id, {
    String? caption,
    String? thumbnail,
  }) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/barber-courses/media/$id',
        data: {
          if (caption != null) 'caption': caption,
          if (thumbnail != null) 'thumbnail': thumbnail,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BarberCourseMediaModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar media',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateCourseMedia error: ${e.message}', error: e);
      throw Exception('Error al actualizar media: ${e.message}');
    }
  }

  @override
  Future<void> deleteCourseMedia(String id) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/barber-courses/media/$id',
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al eliminar media',
        );
      }
    } on DioException catch (e) {
      appLogger.e('DeleteCourseMedia error: ${e.message}', error: e);
      throw Exception('Error al eliminar media: ${e.message}');
    }
  }
}
