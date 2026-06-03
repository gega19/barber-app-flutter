import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/google_login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/become_barber_usecase.dart';
import '../../../domain/usecases/auth/delete_account_usecase.dart';
import '../../../domain/usecases/auth/send_phone_verification_code_usecase.dart';
import '../../../domain/usecases/auth/confirm_phone_verification_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/fcm_token_repository.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/injection/injection.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../data/datasources/local/local_storage.dart';
import 'dart:io';
import 'dart:convert';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final GoogleAuthService googleAuthService;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final BecomeBarberUseCase becomeBarberUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final SendPhoneVerificationCodeUseCase sendPhoneVerificationCodeUseCase;
  final ConfirmPhoneVerificationUseCase confirmPhoneVerificationUseCase;
  final FcmTokenRepository fcmTokenRepository;
  final NotificationService notificationService;
  final AnalyticsService analyticsService = sl<AnalyticsService>();

  AuthCubit({
    required this.loginUseCase,
    required this.googleLoginUseCase,
    required this.googleAuthService,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.becomeBarberUseCase,
    required this.deleteAccountUseCase,
    required this.sendPhoneVerificationCodeUseCase,
    required this.confirmPhoneVerificationUseCase,
    required this.fcmTokenRepository,
    required this.notificationService,
  }) : super(AuthInitial());

  Future<void> init() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold((failure) => emit(AuthInitial()), (user) async {
      if (user != null) {
        if (user.mustUpdatePassword) {
          emit(AuthRequiresPasswordChange(user));
        } else {
          emit(AuthAuthenticated(user));
          // Registrar token FCM si el usuario está autenticado
          await _registerFcmToken();
        }
      } else {
        emit(AuthInitial());
      }
    });
  }

  /// Registra el token FCM en el backend
  Future<void> _registerFcmToken() async {
    try {
      final token = await notificationService.getToken();
      if (token != null) {
        final deviceType = Platform.isAndroid ? 'android' : 'ios';
        print(
          '📱 Registrando token FCM: ${token.substring(0, 20)}... (deviceType: $deviceType)',
        );

        final result = await fcmTokenRepository.registerToken(
          token: token,
          deviceType: deviceType,
        );

        result.fold(
          (failure) {
            print('❌ Error al registrar token FCM: ${failure.message}');
          },
          (_) {
            print('✅ Token FCM registrado exitosamente en el backend');
          },
        );
      } else {
        print('⚠️ No se pudo obtener el token FCM');
      }
    } catch (e) {
      // No emitir error, solo loggear - las notificaciones no son críticas
      print('❌ Error inesperado al registrar token FCM: $e');
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await loginUseCase(email: email, password: password);

    result.fold((failure) => emit(AuthError(failure.message)), (user) async {
      // Validar que las credenciales biométricas guardadas pertenezcan a este usuario
      try {
        final isValid = await SecureStorageService.validateCredentialsForUser(
          user.id,
        );

        if (!isValid) {
          // Las credenciales guardadas pertenecen a otro usuario, limpiarlas
          await SecureStorageService.clearCredentials();
        }
      } catch (e) {
        // No emitir error, solo loggear
        print('Error validating biometric credentials: $e');
      }

      if (user.mustUpdatePassword) {
        emit(AuthRequiresPasswordChange(user));
      } else {
        emit(AuthAuthenticated(user));
        // Registrar token FCM después de login exitoso
        await _registerFcmToken();
        // Track analytics
        await analyticsService.trackEvent(
          eventName: 'user_logged_in',
          eventType: 'user_action',
        );
        await analyticsService.startNewSession();
      }
    });
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());

    try {
      final idToken = await googleAuthService.getIdToken();
      final result = await googleLoginUseCase(idToken: idToken);

      result.fold((failure) => emit(AuthError(failure.message)), (user) async {
        try {
          final isValid = await SecureStorageService.validateCredentialsForUser(
            user.id,
          );
          if (!isValid) {
            await SecureStorageService.clearCredentials();
          }
        } catch (e) {
          print('Error validating biometric credentials: $e');
        }

        if (user.mustUpdatePassword) {
          emit(AuthRequiresPasswordChange(user));
        } else {
          emit(AuthAuthenticated(user));
          await _registerFcmToken();
          await analyticsService.trackEvent(
            eventName: 'user_logged_in_google',
            eventType: 'user_action',
          );
          await analyticsService.startNewSession();
        }
      });
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
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

    result.fold((failure) => emit(AuthError(failure.message)), (user) async {
      emit(AuthAuthenticated(user));
      // Registrar token FCM después de registro exitoso
      await _registerFcmToken();
      // Track analytics
      await analyticsService.trackEvent(
        eventName: 'user_registered',
        eventType: 'user_action',
        properties: {'email': email},
      );
      await analyticsService.startNewSession();
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());

    // Eliminar token FCM antes de hacer logout
    try {
      await fcmTokenRepository.deleteUserTokens();
      await notificationService.deleteToken();
    } catch (e) {
      // No emitir error, solo loggear
      print('Error deleting FCM token: $e');
    }

    // Limpiar credenciales biométricas al hacer logout
    try {
      await SecureStorageService.clearCredentials();
    } catch (e) {
      // No emitir error, solo loggear
      print('Error clearing biometric credentials: $e');
    }

    try {
      await googleAuthService.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }

    final result = await logoutUseCase();
    result.fold((failure) => emit(AuthError(failure.message)), (_) async {
      // Track analytics
      await analyticsService.trackEvent(
        eventName: 'user_logged_out',
        eventType: 'user_action',
      );
      emit(AuthInitial());
    });
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
    result.fold((failure) {
      emit(AuthProfileUpdateError(failure.message, currentUser));
    }, (user) => emit(AuthAuthenticated(user)));
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
    result.fold((failure) {
      emit(AuthProfileUpdateError(failure.message, currentUser));
    }, (user) => emit(AuthAuthenticated(user)));
  }

  Future<bool> deleteAccount({required String password}) async {
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

  /// Envía el código de verificación por SMS (Twilio vía backend).
  /// Retorna (success, errorMessage, retryAfterSeconds).
  /// retryAfterSeconds solo viene cuando el servidor responde 429 (cooldown).
  Future<(bool success, String? errorMessage, int? retryAfterSeconds)>
  sendPhoneVerificationCode(String phone) async {
    final result = await sendPhoneVerificationCodeUseCase(phone);
    return result.fold(
      (failure) => (
        false,
        failure.message,
        failure is ServerFailure ? failure.retryAfterSeconds : null,
      ),
      (_) => (true, null, null),
    );
  }

  /// Confirma la verificación de teléfono con el código SMS (Twilio vía backend).
  Future<(bool success, String? errorMessage)> confirmPhoneVerification(
    String phone,
    String code,
  ) async {
    final result = await confirmPhoneVerificationUseCase(phone, code);
    return result.fold((failure) => (false, failure.message), (user) {
      emit(AuthAuthenticated(user));
      return (true, null);
    });
  }

  /// Actualiza el perfil del usuario desde el servidor (silenciosamente)
  /// Este método obtiene la información más reciente del usuario sin mostrar errores
  Future<void> refreshProfile() async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    try {
      // Obtener usuario actualizado del servidor directamente
      final authRemoteDataSource = sl<AuthRemoteDataSource>();
      final localStorage = sl<LocalStorage>();

      final userModel = await authRemoteDataSource.getCurrentUser();

      // Actualizar almacenamiento local con el usuario actualizado
      await localStorage.saveUserData(jsonEncode(userModel.toJson()));

      // Actualizar el estado con el usuario actualizado (UserModel extiende UserEntity)
      if (userModel.mustUpdatePassword) {
        emit(AuthRequiresPasswordChange(userModel));
      } else {
        emit(AuthAuthenticated(userModel));
      }
    } catch (e) {
      // Silenciosamente fallar - no mostrar errores al usuario
      // Solo loggear en desarrollo
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        print('⚠️ Error al actualizar perfil silenciosamente: $e');
      }
    }
  }

  /// Cambia la contraseña obligatoria del usuario
  Future<void> changePassword(String newPassword) async {
    final currentState = state;
    if (currentState is! AuthRequiresPasswordChange) return;

    final user = currentState.user;
    emit(AuthLoading());

    try {
      final authRepository = sl<AuthRepository>();
      final result = await authRepository.changePassword(newPassword);

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) async {
          // If successful, we manually set mustUpdatePassword to false in state to unlock
          emit(AuthAuthenticated(UserModel.fromEntity(user).copyWith(mustUpdatePassword: false)));
          await _registerFcmToken();
          await analyticsService.trackEvent(
            eventName: 'password_reset_completed',
            eventType: 'user_action',
          );
          await analyticsService.startNewSession();
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
