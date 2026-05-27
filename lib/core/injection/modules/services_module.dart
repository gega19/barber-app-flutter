import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/repositories/country_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/effective_country_code_resolver.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/version_check_service.dart';
import '../../../core/services/phone_auth_service.dart';

/// Módulo para registrar todos los Services
class ServicesModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<EffectiveCountryCodeResolver>(() {
      final countryRepository = sl<CountryRepository>();
      return EffectiveCountryCodeResolver(countryRepository);
    });
    sl.registerLazySingleton<NotificationService>(
      NotificationService.new,
    );
    sl.registerLazySingleton<SocketService>(SocketService.new);
    sl.registerLazySingleton<LocationService>(LocationService.new);
    sl.registerLazySingleton(
      () => AnalyticsService(
        dio: sl<Dio>(),
        prefs: sl<SharedPreferences>(),
        localStorage: sl(),
      ),
    );
    sl.registerLazySingleton<VersionCheckService>(
      () => VersionCheckService(sl<Dio>()),
    );
    sl.registerLazySingleton<PhoneAuthService>(PhoneAuthService.new);
  }
}
