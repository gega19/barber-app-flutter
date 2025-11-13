import 'package:get_it/get_it.dart';
import 'modules/external_module.dart';
import 'modules/data_sources_module.dart';
import 'modules/repositories_module.dart';
import 'modules/use_cases_module.dart';
import 'modules/services_module.dart';
import 'modules/cubits_module.dart';

/// Contenedor de inyección de dependencias
/// 
/// Este archivo coordina el registro de todas las dependencias de la aplicación
/// organizadas en módulos lógicos para facilitar el mantenimiento.
final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
/// 
/// El orden de registro es importante ya que algunas dependencias
/// dependen de otras que deben estar registradas previamente.
/// 
/// Orden de registro:
/// 1. External (SharedPreferences, Dio, LocalStorage)
/// 2. Data Sources (todos los RemoteDataSources)
/// 3. Repositories (implementaciones de repositorios)
/// 4. Use Cases (casos de uso del dominio)
/// 5. Services (servicios globales como NotificationService, SocketService)
/// 6. Cubits (gestores de estado)
Future<void> init() async {
  // 1. External dependencies (SharedPreferences, Dio, LocalStorage)
  await ExternalModule.register(sl);

  // 2. Data Sources
  DataSourcesModule.register(sl);

  // 3. Repositories
  RepositoriesModule.register(sl);

  // 4. Use Cases
  UseCasesModule.register(sl);

  // 5. Services
  ServicesModule.register(sl);

  // 6. Cubits
  CubitsModule.register(sl);
}
