import '../../models/review_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviewsByBarber(String barberId);
  Future<List<ReviewModel>> getReviewsByWorkplace(String workplaceId);
  Future<ReviewModel> createReview({
    String? barberId,
    String? workplaceId,
    required int rating,
    String? comment,
  });
  Future<bool> hasUserReviewedBarber(String barberId);
  Future<bool> hasUserReviewedWorkplace(String workplaceId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;

  ReviewRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ReviewModel>> getReviewsByBarber(String barberId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/reviews/barber/$barberId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener reseñas',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetReviewsByBarber error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener reseñas: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByWorkplace(String workplaceId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/reviews/workplace/$workplaceId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener reseñas',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetReviewsByWorkplace error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener reseñas: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<ReviewModel> createReview({
    String? barberId,
    String? workplaceId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/reviews',
        data: {
          if (barberId != null) 'barberId': barberId,
          if (workplaceId != null) 'workplaceId': workplaceId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ReviewModel.fromJson(data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al crear reseña',
        );
      }
    } on DioException catch (e) {
      appLogger.e('CreateReview error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al crear reseña: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasUserReviewedBarber(String barberId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/reviews/check/barber/$barberId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['hasReviewed'] as bool;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al verificar reseña',
        );
      }
    } on DioException catch (e) {
      appLogger.e('HasUserReviewedBarber error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al verificar reseña: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasUserReviewedWorkplace(String workplaceId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/reviews/check/workplace/$workplaceId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['hasReviewed'] as bool;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al verificar reseña',
        );
      }
    } on DioException catch (e) {
      appLogger.e('HasUserReviewedWorkplace error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al verificar reseña: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}

