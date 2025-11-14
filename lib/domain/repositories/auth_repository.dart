import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Interfaz del repositorio de autenticación
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Cierra sesión
  Future<Either<Failure, void>> logout();

  /// Obtiene el usuario actual (desde almacenamiento local)
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Obtiene el usuario actualizado desde el servidor
  Future<Either<Failure, UserEntity>> refreshCurrentUser();

  /// Obtiene estadísticas del usuario
  Future<Either<Failure, Map<String, dynamic>>> getUserStats();

  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? country,
    String? gender,
    String? avatar,
    String? avatarSeed,
  });

        Future<Either<Failure, UserEntity>> becomeBarber({
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

  Future<Either<Failure, void>> deleteAccount({
    required String password,
  });

  /// Verifica si hay una sesión activa
  Future<bool> isAuthenticated();
}


