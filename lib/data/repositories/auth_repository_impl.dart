import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../models/user_model.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import 'dart:convert';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorage localStorage;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.localStorage, this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validación local
      if (email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('Email y contraseña son requeridos'));
      }

      // Llamada al backend
      final authResponse = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Guardar tokens y usuario
      await localStorage.saveToken(authResponse.accessToken);
      await localStorage.saveRefreshToken(authResponse.refreshToken);
      await localStorage.saveUserData(userModelToJson(authResponse.user));

      return Right(authResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Validación local
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('Todos los campos son requeridos'));
      }

      // Llamada al backend
      final authResponse = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      // Guardar tokens y usuario
      await localStorage.saveToken(authResponse.accessToken);
      await localStorage.saveRefreshToken(authResponse.refreshToken);
      await localStorage.saveUserData(userModelToJson(authResponse.user));

      return Right(authResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Llamar al backend para cerrar sesión
      await remoteDataSource.logout();
      
      // Limpiar datos locales
      await localStorage.clearAll();
      return const Right(null);
    } catch (e) {
      // Aunque falle el logout del servidor, limpiamos localmente
      await localStorage.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userData = await localStorage.getUserData();
      if (userData == null) return const Right(null);

      final userMap = userModelFromJson(userData);
      return Right(userMap);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserStats() async {
    try {
      final stats = await remoteDataSource.getUserStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? country,
    String? gender,
    String? avatar,
    String? avatarSeed,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        location: location,
        country: country,
        gender: gender,
        avatar: avatar,
        avatarSeed: avatarSeed,
      );

      // Update local storage with new user data
      await localStorage.saveUserData(userModelToJson(updatedUser));

      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
          } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.becomeBarber(
        specialtyId: specialtyId,
        specialty: specialty,
        experienceYears: experienceYears,
        location: location,
        latitude: latitude,
        longitude: longitude,
        image: image,
        workplaceId: workplaceId,
        serviceType: serviceType,
      );
      
      final updatedUser = result['user'] as UserModel;
      await localStorage.saveUserData(userModelToJson(updatedUser));
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  }) async {
    try {
      if (password.isEmpty) {
        return const Left(ValidationFailure('Debes ingresar tu contraseña'));
      }

      await remoteDataSource.deleteAccount(password: password);
      await localStorage.clearAll();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

    @override
    Future<bool> isAuthenticated() async {
      final token = await localStorage.getToken();
      return token != null && token.isNotEmpty;
    }

  String userModelToJson(UserModel user) {
    // Serialización JSON usando el método toJson del modelo
    return jsonEncode(user.toJson());
  }

  UserModel userModelFromJson(String jsonString) {
    // Parse JSON real
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }
}

