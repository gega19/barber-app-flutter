import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/become_barber_usecase.dart';
import '../../../domain/usecases/auth/delete_account_usecase.dart';
import '../../../core/services/secure_storage_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final BecomeBarberUseCase becomeBarberUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.becomeBarberUseCase,
    required this.deleteAccountUseCase,
  }) : super(AuthInitial());

  Future<void> init() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthInitial()),
      (user) => user != null ? emit(AuthAuthenticated(user)) : emit(AuthInitial()),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(email: email, password: password);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    
    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? country,
    String? gender,
    String? avatar,
    String? avatarSeed,
  }) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;
    
    final currentUser = currentState.user;
    
    final result = await updateProfileUseCase(
      name: name,
      phone: phone,
      location: location,
      country: country,
      gender: gender,
      avatar: avatar,
      avatarSeed: avatarSeed,
    );
    result.fold(
      (failure) {
        emit(AuthProfileUpdateError(failure.message, currentUser));
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

    Future<void> becomeBarber({
    String? specialtyId,
    required String specialty,
    required int experienceYears,
    required String location,
    double? latitude,
    double? longitude,
    String? image,
    }) async {
      final currentState = state;
      if (currentState is! AuthAuthenticated) return;
      
      final currentUser = currentState.user;
      
    final result = await becomeBarberUseCase(
        specialtyId: specialtyId,
        specialty: specialty,
        experienceYears: experienceYears,
        location: location,
        latitude: latitude,
        longitude: longitude,
        image: image,
      );
    result.fold(
      (failure) {
        emit(AuthProfileUpdateError(failure.message, currentUser));
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<bool> deleteAccount({
    required String password,
  }) async {
    final currentState = state;
    UserEntity? currentUser;

    if (currentState is AuthAuthenticated) {
      currentUser = currentState.user;
    } else if (currentState is AuthProfileUpdateError) {
      currentUser = currentState.user;
    } else {
      return false;
    }

    emit(AuthLoading());

    final result = await deleteAccountUseCase(password: password);
    bool success = false;

    await result.fold(
      (failure) async {
        if (currentUser != null) {
          emit(AuthProfileUpdateError(failure.message, currentUser));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (_) async {
        await SecureStorageService.clearCredentials();
        success = true;
        emit(AuthInitial());
      },
    );

    return success;
  }
}


