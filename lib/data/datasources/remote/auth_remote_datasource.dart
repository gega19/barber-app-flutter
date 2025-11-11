import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

/// Interfaz para el datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
  
  Future<String> refreshToken(String refreshToken);
  
  Future<UserModel> getCurrentUser();
  
  Future<Map<String, dynamic>> getUserStats();
  
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? country,
    String? gender,
    String? avatar,
    String? avatarSeed,
  });
  
  Future<Map<String, dynamic>> becomeBarber({
    String? specialtyId,
    required String specialty,
    required int experienceYears,
    required String location,
    double? latitude,
    double? longitude,
    String? image,
    String? workplaceId,
    String? serviceType,
  });
  
  Future<void> updateBarberStep2({
    String? workplaceId,
    String? serviceType,
  });

  Future<void> deleteAccount({
    required String password,
  });
}

/// Respuesta de autenticación del backend
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

/// Implementación del datasource remoto
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Backend returns { success, data: { user, accessToken, refreshToken }, message }
        final data = response.data['data'] as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error en el login',
        );
      }
    } on DioException catch (e) {
      appLogger.e('Login error: ${e.message}', error: e);
      
      // Manejo específico por tipo de error
      if (e.response != null) {
        String message = 'Error en el servidor';
        
        if (e.response!.data is Map) {
          final data = e.response!.data as Map;
          if (data['message'] != null) {
            message = data['message'].toString();
            
            // Mensaje más amigable si es error de base de datos
            if (message.contains('Authentication failed against database') || 
                message.contains('PrismaClientInitializationError')) {
              message = 'El servidor no puede conectarse a la base de datos. Por favor, verifica que PostgreSQL esté corriendo correctamente.';
            }
          }
        }
        
        throw ServerException(message);
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No se puede conectar al servidor. Verifica la IP del backend.');
      }
      
      throw ServerException('Error desconocido: ${e.message}');
    } catch (e) {
      appLogger.e('Unexpected error in login', error: e);
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        // Backend returns { success, data: { user, accessToken, refreshToken }, message }
        final data = response.data['data'] as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error en el registro',
        );
      }
    } on DioException catch (e) {
      appLogger.e('Register error: ${e.message}', error: e);
      
      // Manejo específico por tipo de error
      if (e.response != null) {
        final message = e.response!.data is Map && e.response!.data['message'] != null
            ? e.response!.data['message']
            : 'Error en el servidor';
        throw ServerException(message);
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No se puede conectar al servidor. Verifica la IP del backend.');
      }
      
      throw ServerException('Error desconocido: ${e.message}');
    } catch (e) {
      appLogger.e('Unexpected error in register', error: e);
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount({
    required String password,
  }) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/auth/delete-account',
        data: {
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al eliminar la cuenta',
        );
      }
    } on DioException catch (e) {
      appLogger.e('DeleteAccount error: ${e.message}', error: e);

      if (e.response != null) {
        final message = e.response!.data is Map && e.response!.data['message'] != null
            ? e.response!.data['message']
            : 'Error en el servidor';
        throw ServerException(message);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }

      throw ServerException('Error desconocido: ${e.message}');
    } catch (e) {
      appLogger.e('Unexpected error in deleteAccount', error: e);
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('${AppConstants.baseUrl}/api/auth/logout');
    } on DioException catch (e) {
      appLogger.e('Logout error: ${e.message}', error: e);
      // No lanzamos error, simplemente logueamos
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['accessToken'] as String;
      } else {
        throw ServerException(response.data['message'] ?? 'Error al refrescar token');
      }
    } on DioException catch (e) {
      appLogger.e('RefreshToken error: ${e.message}', error: e);
      throw ServerException(e.response?.data['message'] ?? 'Error al refrescar token');
    } catch (e) {
      appLogger.e('Unexpected error in refreshToken: $e', error: e);
      throw ServerException('Error inesperado al refrescar token');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/auth/me');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener usuario',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetCurrentUser error: ${e.message}', error: e);
      throw ServerException('Error al obtener usuario: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/auth/stats');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener estadísticas',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetUserStats error: ${e.message}', error: e);
      throw ServerException('Error al obtener estadísticas: ${e.message}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? country,
    String? gender,
    String? avatar,
    String? avatarSeed,
  }) async {
    try {
      final Map<String, dynamic> requestData = {};
      if (name != null) requestData['name'] = name;
      if (phone != null) requestData['phone'] = phone;
      if (location != null) requestData['location'] = location;
      if (country != null) requestData['country'] = country;
      if (gender != null) requestData['gender'] = gender;
      if (avatar != null) requestData['avatar'] = avatar;
      if (avatarSeed != null) requestData['avatarSeed'] = avatarSeed;

      final response = await dio.put(
        '${AppConstants.baseUrl}/api/auth/profile',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar perfil',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateProfile error: ${e.message}', error: e);
      throw ServerException('Error al actualizar perfil: ${e.message}');
    }
  }

                  @override
          Future<Map<String, dynamic>> becomeBarber({
            String? specialtyId,
            required String specialty,
            required int experienceYears,
            required String location,
            double? latitude,
            double? longitude,
            String? image,
            String? workplaceId,
            String? serviceType,
          }) async {
            try {
              final response = await dio.post(
                '${AppConstants.baseUrl}/api/auth/become-barber',
                data: {
                  if (specialtyId != null) 'specialtyId': specialtyId,
                  'specialty': specialty,
                  'experienceYears': experienceYears,
                  'location': location,
                  if (latitude != null) 'latitude': latitude,
                  if (longitude != null) 'longitude': longitude,
                  if (image != null) 'image': image,
                  if (workplaceId != null) 'workplaceId': workplaceId,
                  if (serviceType != null) 'serviceType': serviceType,
                },
              );
        
              if (response.statusCode == 200) {
                final data = response.data['data'] as Map<String, dynamic>;
                return {
                  'user': UserModel.fromJson(data['user'] as Map<String, dynamic>),
                  'barberId': data['barberId'] as String,
                };
              } else {
                throw DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  message: response.data['message'] ?? 'Error al convertirse en barbero',
                );
              }
            } on DioException catch (e) {
              appLogger.e('BecomeBarber error: ${e.message}', error: e);
              throw ServerException('Error al convertirse en barbero: ${e.message}');
            }
          }

  @override
  Future<void> updateBarberStep2({
    String? workplaceId,
    String? serviceType,
  }) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/auth/become-barber/step2',
        data: {
          if (workplaceId != null) 'workplaceId': workplaceId,
          if (serviceType != null) 'serviceType': serviceType,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al actualizar perfil de barbero',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateBarberStep2 error: ${e.message}', error: e);
      throw ServerException('Error al actualizar perfil de barbero: ${e.message}');
    }
  }
}

/// Excepciones personalizadas
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

