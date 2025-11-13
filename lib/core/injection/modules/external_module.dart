import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../dio_config.dart';
import '../../../../data/datasources/local/local_storage.dart';

/// Módulo para dependencias externas (SharedPreferences, Dio, etc.)
class ExternalModule {
  static Future<void> register(GetIt sl) async {
    // External
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);

    // HTTP Client
    sl.registerLazySingleton<Dio>(() => DioConfig.createDio(sl));

    // Local Storage
    sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sl()));
  }
}
