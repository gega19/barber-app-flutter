import 'package:get_it/get_it.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/fcm_token_repository_impl.dart';
import '../../../data/repositories/barber_repository_impl.dart';
import '../../../data/repositories/appointment_repository_impl.dart';
import '../../../data/repositories/promotion_repository_impl.dart';
import '../../../data/repositories/workplace_repository_impl.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../../../data/repositories/payment_method_repository_impl.dart';
import '../../../data/repositories/barber_availability_repository_impl.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/barber_repository.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/repositories/promotion_repository.dart';
import '../../../domain/repositories/workplace_repository.dart';
import '../../../domain/repositories/review_repository.dart';
import '../../../domain/repositories/payment_method_repository.dart';
import '../../../domain/repositories/barber_availability_repository.dart';
import '../../../domain/repositories/fcm_token_repository.dart';

/// Módulo para registrar todos los Repositories
class RepositoriesModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    );
    sl.registerLazySingleton<BarberRepository>(
      () => BarberRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<PromotionRepository>(
      () => PromotionRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<WorkplaceRepository>(
      () => WorkplaceRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<ReviewRepository>(
      () => ReviewRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<PaymentMethodRepository>(
      () => PaymentMethodRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<BarberAvailabilityRepository>(
      () => BarberAvailabilityRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<FcmTokenRepository>(
      () => FcmTokenRepositoryImpl(sl()),
    );
  }
}

