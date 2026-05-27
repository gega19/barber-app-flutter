import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

/// Interfaz para el datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({required String email, required String password});

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? country,
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

  Future<void> updateBarberStep2({String? workplaceId, String? serviceType});

  Future<void> sendPhoneVerificationCode(String phone);

  Future<UserModel> confirmPhoneVerification(String phone, String code);

  Future<void> deleteAccount({required String password});

  Future<void> requestPasswordResetCode({required String email});

  Future<void> changePassword({required String newPassword});
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
        data: {'email': email, 'password': password},
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
        String message = _extractErrorMessage(e.response!.data);

        // Mensaje más amigable si es error de base de datos
        if (message.contains('Authentication failed against database') ||
            message.contains('PrismaClientInitializationError')) {
          message =
              'El servidor no puede conectarse a la base de datos. Por favor, verifica que PostgreSQL esté corriendo correctamente.';
        }

        throw ServerException(message);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No se puede conectar al servidor. Verifica la IP del backend.',
        );
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
    String? country,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      };
      if (country != null && country.isNotEmpty) {
        data['country'] = country;
      }

      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/register',
        data: data,
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
        final message = _extractErrorMessage(e.response!.data);
        throw ServerException(message);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No se puede conectar al servidor. Verifica la IP del backend.',
        );
      }

      throw ServerException('Error desconocido: ${e.message}');
    } catch (e) {
      appLogger.e('Unexpected error in register', error: e);
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> requestPasswordResetCode({required String email}) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/request-password-reset-code',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al enviar código',
        );
      }
    } on DioException catch (e) {
      appLogger.e('RequestPasswordResetCode error: ${e.message}', error: e);

      if (e.response != null) {
        final message = _extractErrorMessage(e.response!.data);
        throw ServerException(message);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }

      throw ServerException('Error desconocido: ${e.message}');
    } catch (e) {
      appLogger.e('Unexpected error in requestPasswordResetCode', error: e);
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/auth/delete-account',
        data: {'password': password},
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
        final message =
            e.response!.data is Map && e.response!.data['message'] != null
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
        throw ServerException(
          response.data['message'] ?? 'Error al refrescar token',
        );
      }
    } on DioException catch (e) {
      appLogger.e('RefreshToken error: ${e.message}', error: e);
      throw ServerException(
        e.response?.data['message'] ?? 'Error al refrescar token',
      );
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
          message:
              response.data['message'] ?? 'Error al convertirse en barbero',
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
          message:
              response.data['message'] ??
              'Error al actualizar perfil de barbero',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateBarberStep2 error: ${e.message}', error: e);
      throw ServerException(
        'Error al actualizar perfil de barbero: ${e.message}',
      );
    }
  }

  @override
  Future<void> sendPhoneVerificationCode(String phone) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/send-phone-code',
        data: {'phone': phone},
      );
      if (response.statusCode == 429) {
        final data = response.data is Map ? response.data as Map : null;
        final msg =
            data?['message'] ?? 'Espera antes de solicitar otro código.';
        final seconds = data?['retryAfterSeconds'];
        throw ServerException(msg, seconds is int ? seconds : null);
      }
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al enviar el código',
        );
      }
    } on DioException catch (e) {
      appLogger.e('SendPhoneVerificationCode error: ${e.message}', error: e);
      if (e.response?.statusCode == 429) {
        final data = e.response?.data is Map ? e.response!.data as Map : null;
        final seconds = data?['retryAfterSeconds'];
        throw ServerException(
          e.response?.data['message'] ??
              'Espera antes de solicitar otro código.',
          seconds is int ? seconds : null,
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Error al enviar el código',
      );
    }
  }

  @override
  Future<UserModel> confirmPhoneVerification(String phone, String code) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/auth/confirm-phone',
        data: {'phone': phone, 'code': code},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al verificar teléfono',
        );
      }
    } on DioException catch (e) {
      appLogger.e('ConfirmPhoneVerification error: ${e.message}', error: e);
      throw ServerException(
        e.response?.data['message'] ?? 'Error al verificar teléfono',
      );
    }
  }

  /// Extrae el mensaje de error de la respuesta del servidor
  /// Prioriza el array de errors (validación) sobre el campo message
  /// Traduce los mensajes comunes del inglés al español
  String _extractErrorMessage(dynamic responseData) {
    String message = 'Error en el servidor';

    if (responseData is Map) {
      final data = responseData;

      // Primero intentar obtener el mensaje de errors array (validación)
      if (data['errors'] != null && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty && errors[0] is Map) {
          final firstError = errors[0] as Map;
          if (firstError['msg'] != null) {
            message = firstError['msg'].toString();
            return _translateErrorMessage(message);
          }
        }
      }

      // Si no hay errors array, intentar obtener message
      if (data['message'] != null) {
        message = data['message'].toString();
      }
    }

    return _translateErrorMessage(message);
  }

  /// Traduce mensajes de error comunes del inglés al español
  String _translateErrorMessage(String message) {
    // Traducciones de mensajes comunes de validación
    final translations = {
      'Password must contain at least one uppercase letter, one lowercase letter, and one number':
          'La contraseña debe contener al menos una letra mayúscula, una letra minúscula y un número',
      'Password must be at least': 'La contraseña debe tener al menos',
      'characters long': 'caracteres de longitud',
      'Email is required': 'El correo electrónico es requerido',
      'Email must be a valid email': 'El correo electrónico debe ser válido',
      'Invalid email format': 'Formato de correo electrónico inválido',
      'Name is required': 'El nombre es requerido',
      'Password is required': 'La contraseña es requerida',
      'Password must be at least 8 characters':
          'La contraseña debe tener al menos 8 caracteres',
      'User already exists': 'El usuario ya existe',
      'User not found': 'Usuario no encontrado',
      'User not found with this email': 'No existe usuario con ese correo',
      'Invalid credentials': 'Credenciales inválidas',
      'Invalid password': 'Contraseña inválida',
      'Email already registered': 'El correo electrónico ya está registrado',
      'Authentication failed': 'Autenticación fallida',
      'Token expired': 'Token expirado',
      'Unauthorized': 'No autorizado',
      'Forbidden': 'Acceso prohibido',
      'Not found': 'No encontrado',
      'Internal server error': 'Error interno del servidor',
      'Bad request': 'Solicitud incorrecta',
      'Validation failed': 'Validación fallida',
      'Phone is already verified and cannot be changed':
          'El teléfono ya está verificado y no se puede cambiar',
      'Phone number is already in use by another account':
          'Este número ya está en uso por otra cuenta',
      'Invalid or expired verification code':
          'Código inválido o expirado. Solicita uno nuevo.',
      'Phone verification is not configured (Twilio).':
          'La verificación por teléfono no está configurada.',
    };

    // Buscar traducción exacta
    if (translations.containsKey(message)) {
      return translations[message]!;
    }

    // Buscar traducciones parciales (para mensajes que contienen el texto)
    for (final entry in translations.entries) {
      if (message.contains(entry.key)) {
        return message.replaceAll(entry.key, entry.value);
      }
    }

    return message;
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    try {
      await dio.put(
        '${AppConstants.baseUrl}/api/auth/change-password',
        data: {'newPassword': newPassword},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final message = _extractErrorMessage(e.response!.data);
        throw ServerException(message);
      }
      throw ServerException('Error desconocido al cambiar la contraseña');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}

/// Excepciones personalizadas

class ServerException implements Exception {
  final String message;
  final int? retryAfterSeconds;

  ServerException(this.message, [this.retryAfterSeconds]);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}
