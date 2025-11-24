import 'package:get_it/get_it.dart';
import '../../../presentation/cubit/auth/auth_cubit.dart';
import '../../../presentation/cubit/socket/socket_cubit.dart';
import '../../../presentation/cubit/barber/barber_cubit.dart';
import '../../../presentation/cubit/appointment/appointment_cubit.dart';
import '../../../presentation/cubit/barber_queue/barber_queue_cubit.dart';
import '../../../presentation/cubit/promotion/promotion_cubit.dart';
import '../../../presentation/cubit/workplace/workplace_cubit.dart';
import '../../../presentation/cubit/review/review_cubit.dart';
import '../../../presentation/cubit/payment_method/payment_method_cubit.dart';
import '../../../presentation/cubit/barber_availability/barber_availability_cubit.dart';
import '../../../presentation/cubit/barber_course/barber_course_cubit.dart';
import '../../../presentation/cubit/map/map_cubit.dart';

/// Módulo para registrar todos los Cubits
class CubitsModule {
  static void register(GetIt sl) {
    // AuthCubit es Singleton porque mantiene el estado global de autenticación
    sl.registerSingleton<AuthCubit>(
      AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        updateProfileUseCase: sl(),
        becomeBarberUseCase: sl(),
        deleteAccountUseCase: sl(),
        fcmTokenRepository: sl(),
        notificationService: sl(),
      )..init(),
    );

    // Los demás Cubits son Factory porque se crean por pantalla/contexto
    sl.registerFactory(
      () => BarberCubit(
        getBarbersUseCase: sl(),
        getBestBarbersUseCase: sl(),
        searchBarbersUseCase: sl(),
      ),
    );
    sl.registerFactory(() => BarberQueueCubit(sl()));
    sl.registerFactory(
      () => AppointmentCubit(
        getAppointmentsUseCase: sl(),
        createAppointmentUseCase: sl(),
        cancelAppointmentUseCase: sl(),
        markAsAttendedUseCase: sl(),
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
    sl.registerFactory(
      () => PaymentMethodCubit(getPaymentMethodsUseCase: sl()),
    );
    sl.registerFactory(
      () => BarberAvailabilityCubit(
        getMyAvailabilityUseCase: sl(),
        updateMyAvailabilityUseCase: sl(),
      ),
    );
    sl.registerFactory(
      () => BarberCourseCubit(
        getBarberCoursesUseCase: sl(),
        getCourseByIdUseCase: sl(),
        createCourseUseCase: sl(),
        updateCourseUseCase: sl(),
        deleteCourseUseCase: sl(),
      ),
    );
    sl.registerFactory(() => SocketCubit(sl()));
    sl.registerFactory(
      () => MapCubit(
        getWorkplacesUseCase: sl(),
        getNearbyWorkplacesUseCase: sl(),
        locationService: sl(),
      ),
    );
  }
}
