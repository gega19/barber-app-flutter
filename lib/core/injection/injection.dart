import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/barber_remote_datasource.dart';
import '../../data/datasources/remote/specialty_remote_datasource.dart';
import '../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../data/datasources/remote/service_remote_datasource.dart';
import '../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../data/datasources/remote/workplace_media_remote_datasource.dart';
import '../../data/datasources/remote/upload_remote_datasource.dart';
import '../../data/datasources/remote/appointment_remote_datasource.dart';
import '../../data/datasources/remote/promotion_remote_datasource.dart';
import '../../data/datasources/remote/review_remote_datasource.dart';
import '../../data/datasources/remote/payment_method_remote_datasource.dart';
import '../../data/datasources/remote/barber_availability_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/barber_repository_impl.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/promotion_repository_impl.dart';
import '../../data/repositories/workplace_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/payment_method_repository_impl.dart';
import '../../data/repositories/barber_availability_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/barber_repository.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../../domain/repositories/workplace_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../domain/repositories/barber_availability_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/get_user_stats_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/become_barber_usecase.dart';
import '../../domain/usecases/auth/delete_account_usecase.dart';
import '../../domain/usecases/barber/get_barbers_usecase.dart';
import '../../domain/usecases/barber/get_best_barbers_usecase.dart';
import '../../domain/usecases/barber/search_barbers_usecase.dart';
import '../../domain/usecases/appointment/get_appointments_usecase.dart';
import '../../domain/usecases/appointment/create_appointment_usecase.dart';
import '../../domain/usecases/promotion/get_promotions_usecase.dart';
import '../../domain/usecases/workplace/get_workplaces_usecase.dart';
import '../../domain/usecases/review/get_reviews_by_barber_usecase.dart';
import '../../domain/usecases/review/get_reviews_by_workplace_usecase.dart';
import '../../domain/usecases/review/create_review_usecase.dart';
import '../../domain/usecases/review/has_user_reviewed_barber_usecase.dart';
import '../../domain/usecases/review/has_user_reviewed_workplace_usecase.dart';
import '../../domain/usecases/payment_method/get_payment_methods_usecase.dart';
import '../../domain/usecases/barber_availability/get_my_availability_usecase.dart';
import '../../domain/usecases/barber_availability/update_my_availability_usecase.dart';
import '../../domain/usecases/barber_availability/get_available_slots_usecase.dart';
import '../../presentation/cubit/auth/auth_cubit.dart';
import '../../presentation/cubit/barber/barber_cubit.dart';
import '../../presentation/cubit/appointment/appointment_cubit.dart';
import '../../presentation/cubit/promotion/promotion_cubit.dart';
import '../../presentation/cubit/workplace/workplace_cubit.dart';
import '../../presentation/cubit/review/review_cubit.dart';
import '../../presentation/cubit/payment_method/payment_method_cubit.dart';
import '../../presentation/cubit/barber_availability/barber_availability_cubit.dart';

/// Contenedor de inyección de dependencias
final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP Client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    bool isRefreshing = false;
    final List<Map<String, dynamic>> failedQueue = [];

    // Add auth interceptor to include token in requests and handle token refresh
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for refresh-token endpoint to avoid loops
          if (options.path.contains('/refresh-token')) {
            handler.next(options);
            return;
          }

          try {
            final localStorage = sl<LocalStorage>();
            final token = await localStorage.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            print('⚠️ Error getting token: $e');
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          // Skip refresh for refresh-token endpoint
          if (error.requestOptions.path.contains('/refresh-token')) {
            handler.next(error);
            return;
          }

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final localStorage = sl<LocalStorage>();
            final refreshToken = await localStorage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              // No refresh token available, logout
              print('⚠️ No refresh token available, logging out...');
              await localStorage.clearAll();
              handler.next(error);
              return;
            }

            // If already refreshing, queue this request
            if (isRefreshing) {
              failedQueue.add({
                'requestOptions': error.requestOptions,
                'handler': handler,
              });
              return;
            }

            isRefreshing = true;

            try {
              // Try to refresh the token
              final authDataSource = sl<AuthRemoteDataSource>();
              final newAccessToken = await authDataSource.refreshToken(
                refreshToken,
              );

              // Save new token
              await localStorage.saveToken(newAccessToken);

              // Update the failed request with new token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              // Retry the original request
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);

              // Process queued requests
              for (final item in failedQueue) {
                try {
                  final requestOptions =
                      item['requestOptions'] as RequestOptions;
                  final itemHandler =
                      item['handler'] as ErrorInterceptorHandler;
                  requestOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  final retryResponse = await dio.fetch(requestOptions);
                  itemHandler.resolve(retryResponse);
                } catch (e) {
                  final itemHandler =
                      item['handler'] as ErrorInterceptorHandler;
                  itemHandler.reject(error);
                }
              }
              failedQueue.clear();
            } catch (refreshError) {
              // Refresh failed, logout and reject all requests
              print('⚠️ Token refresh failed, logging out...');
              await localStorage.clearAll();

              // Reject all queued requests
              for (final item in failedQueue) {
                final itemHandler = item['handler'] as ErrorInterceptorHandler;
                itemHandler.reject(error);
              }
              failedQueue.clear();

              handler.next(error);
            } finally {
              isRefreshing = false;
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    return dio;
  });

  // Data Sources
  sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BarberRemoteDataSource>(
    () => BarberRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SpecialtyRemoteDataSource>(
    () => SpecialtyRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WorkplaceRemoteDataSource>(
    () => WorkplaceRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BarberMediaRemoteDataSource>(
    () => BarberMediaRemoteDataSourceImpl(sl()),
  );

  // Workplace Media
  sl.registerLazySingleton<WorkplaceMediaRemoteDataSource>(
    () => WorkplaceMediaRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UploadRemoteDataSource>(
    () => UploadRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PaymentMethodRemoteDataSource>(
    () => PaymentMethodRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BarberAvailabilityRemoteDataSource>(
    () => BarberAvailabilityRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<BarberRepository>(() => BarberRepositoryImpl(sl()));
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WorkplaceRepository>(
    () => WorkplaceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(sl()));
  sl.registerLazySingleton<PaymentMethodRepository>(
    () => PaymentMethodRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BarberAvailabilityRepository>(
    () => BarberAvailabilityRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => BecomeBarberUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetBarbersUseCase(sl()));
  sl.registerLazySingleton(() => GetBestBarbersUseCase(sl()));
  sl.registerLazySingleton(() => SearchBarbersUseCase(sl()));
  sl.registerLazySingleton(() => GetAppointmentsUseCase(sl()));
  sl.registerLazySingleton(() => CreateAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => GetPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkplacesUseCase(sl()));
  sl.registerLazySingleton(() => GetReviewsByBarberUseCase(sl()));
  sl.registerLazySingleton(() => GetReviewsByWorkplaceUseCase(sl()));
  sl.registerLazySingleton(() => CreateReviewUseCase(sl()));
  sl.registerLazySingleton(() => HasUserReviewedBarberUseCase(sl()));
  sl.registerLazySingleton(() => HasUserReviewedWorkplaceUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentMethodsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMyAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableSlotsUseCase(sl()));

  // Cubits
  sl.registerSingleton<AuthCubit>(
    AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      updateProfileUseCase: sl(),
      becomeBarberUseCase: sl(),
      deleteAccountUseCase: sl(),
    )..init(),
  );
  sl.registerFactory(
    () => BarberCubit(
      getBarbersUseCase: sl(),
      getBestBarbersUseCase: sl(),
      searchBarbersUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AppointmentCubit(
      getAppointmentsUseCase: sl(),
      createAppointmentUseCase: sl(),
    ),
  );
  sl.registerFactory(() => PromotionCubit(getPromotionsUseCase: sl()));
  sl.registerFactory(() => WorkplaceCubit(getWorkplacesUseCase: sl()));
  sl.registerFactory(
    () => ReviewCubit(
      getReviewsByBarberUseCase: sl(),
      getReviewsByWorkplaceUseCase: sl(),
      createReviewUseCase: sl(),
      hasUserReviewedBarberUseCase: sl(),
      hasUserReviewedWorkplaceUseCase: sl(),
    ),
  );
  sl.registerFactory(() => PaymentMethodCubit(getPaymentMethodsUseCase: sl()));
  sl.registerFactory(
    () => BarberAvailabilityCubit(
      getMyAvailabilityUseCase: sl(),
      updateMyAvailabilityUseCase: sl(),
    ),
  );
}
