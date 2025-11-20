import 'package:get_it/get_it.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/location_service.dart';

/// Módulo para registrar todos los Services
class ServicesModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton(() => NotificationService());
    sl.registerLazySingleton(() => SocketService());
    sl.registerLazySingleton(() => LocationService());
  }
}
