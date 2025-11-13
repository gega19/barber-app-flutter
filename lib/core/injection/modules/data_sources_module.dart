import 'package:get_it/get_it.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../data/datasources/remote/barber_remote_datasource.dart';
import '../../../data/datasources/remote/specialty_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_media_remote_datasource.dart';
import '../../../data/datasources/remote/upload_remote_datasource.dart';
import '../../../data/datasources/remote/appointment_remote_datasource.dart';
import '../../../data/datasources/remote/promotion_remote_datasource.dart';
import '../../../data/datasources/remote/review_remote_datasource.dart';
import '../../../data/datasources/remote/payment_method_remote_datasource.dart';
import '../../../data/datasources/remote/barber_availability_remote_datasource.dart';
import '../../../data/datasources/remote/fcm_token_remote_datasource.dart';

/// Módulo para registrar todos los DataSources
class DataSourcesModule {
  static void register(GetIt sl) {
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
    sl.registerLazySingleton<FcmTokenRemoteDataSource>(
      () => FcmTokenRemoteDataSourceImpl(sl()),
    );
  }
}
