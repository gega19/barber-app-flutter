import 'package:get_it/get_it.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/get_user_stats_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/auth/become_barber_usecase.dart';
import '../../../domain/usecases/auth/delete_account_usecase.dart';
import '../../../domain/usecases/barber/get_barbers_usecase.dart';
import '../../../domain/usecases/barber/get_best_barbers_usecase.dart';
import '../../../domain/usecases/barber/search_barbers_usecase.dart';
import '../../../domain/usecases/appointment/get_appointments_usecase.dart';
import '../../../domain/usecases/appointment/create_appointment_usecase.dart';
import '../../../domain/usecases/appointment/cancel_appointment_usecase.dart';
import '../../../domain/usecases/appointment/mark_as_attended_usecase.dart';
import '../../../domain/usecases/promotion/get_promotions_usecase.dart';
import '../../../domain/usecases/workplace/get_workplaces_usecase.dart';
import '../../../domain/usecases/workplace/get_nearby_workplaces_usecase.dart';
import '../../../domain/usecases/review/get_reviews_by_barber_usecase.dart';
import '../../../domain/usecases/review/get_reviews_by_workplace_usecase.dart';
import '../../../domain/usecases/review/create_review_usecase.dart';
import '../../../domain/usecases/review/has_user_reviewed_barber_usecase.dart';
import '../../../domain/usecases/review/has_user_reviewed_workplace_usecase.dart';
import '../../../domain/usecases/payment_method/get_payment_methods_usecase.dart';
import '../../../domain/usecases/barber_availability/get_my_availability_usecase.dart';
import '../../../domain/usecases/barber_availability/update_my_availability_usecase.dart';
import '../../../domain/usecases/barber_availability/get_available_slots_usecase.dart';
import '../../../domain/usecases/barber_course/get_barber_courses_usecase.dart';
import '../../../domain/usecases/barber_course/get_course_by_id_usecase.dart';
import '../../../domain/usecases/barber_course/create_course_usecase.dart';
import '../../../domain/usecases/barber_course/update_course_usecase.dart';
import '../../../domain/usecases/barber_course/delete_course_usecase.dart';

/// Módulo para registrar todos los UseCases
class UseCasesModule {
  static void register(GetIt sl) {
    // Auth UseCases
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
    sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
    sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
    sl.registerLazySingleton(() => BecomeBarberUseCase(sl()));
    sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

    // Barber UseCases
    sl.registerLazySingleton(() => GetBarbersUseCase(sl()));
    sl.registerLazySingleton(() => GetBestBarbersUseCase(sl()));
    sl.registerLazySingleton(() => SearchBarbersUseCase(sl()));

    // Appointment UseCases
    sl.registerLazySingleton(() => GetAppointmentsUseCase(sl()));
    sl.registerLazySingleton(() => CreateAppointmentUseCase(sl()));
    sl.registerLazySingleton(() => CancelAppointmentUseCase(sl()));
    sl.registerLazySingleton(() => MarkAsAttendedUseCase(sl()));

    // Promotion UseCases
    sl.registerLazySingleton(() => GetPromotionsUseCase(sl()));

    // Workplace UseCases
    sl.registerLazySingleton(() => GetWorkplacesUseCase(sl()));
    sl.registerLazySingleton(() => GetNearbyWorkplacesUseCase(sl()));

    // Review UseCases
    sl.registerLazySingleton(() => GetReviewsByBarberUseCase(sl()));
    sl.registerLazySingleton(() => GetReviewsByWorkplaceUseCase(sl()));
    sl.registerLazySingleton(() => CreateReviewUseCase(sl()));
    sl.registerLazySingleton(() => HasUserReviewedBarberUseCase(sl()));
    sl.registerLazySingleton(() => HasUserReviewedWorkplaceUseCase(sl()));

    // Payment Method UseCases
    sl.registerLazySingleton(() => GetPaymentMethodsUseCase(sl()));

    // Barber Availability UseCases
    sl.registerLazySingleton(() => GetMyAvailabilityUseCase(sl()));
    sl.registerLazySingleton(() => UpdateMyAvailabilityUseCase(sl()));
    sl.registerLazySingleton(() => GetAvailableSlotsUseCase(sl()));

    // Barber Course UseCases
    sl.registerLazySingleton(() => GetBarberCoursesUseCase(sl()));
    sl.registerLazySingleton(() => GetCourseByIdUseCase(sl()));
    sl.registerLazySingleton(() => CreateCourseUseCase(sl()));
    sl.registerLazySingleton(() => UpdateCourseUseCase(sl()));
    sl.registerLazySingleton(() => DeleteCourseUseCase(sl()));
  }
}
