# Barber Appointment App

Aplicación móvil para reservas de citas en barbería desarrollada con Flutter, implementando Clean Architecture y BLoC (Cubit) pattern.

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con separación de responsabilidades en 3 capas principales:

### 📁 Estructura del Proyecto

```
lib/
├── core/                    # Código compartido
│   ├── constants/          # Constantes de la app
│   ├── theme/              # Configuración de temas
│   ├── utils/              # Utilidades y extensiones
│   ├── errors/             # Manejo de errores
│   ├── injection/           # Inyección de dependencias
│   └── routing/             # Configuración de rutas
│
├── domain/                  # Capa de Dominio (Lógica de negocio)
│   ├── entities/           # Entidades del dominio
│   ├── repositories/        # Interfaces de repositorios
│   └── usecases/           # Casos de uso
│
├── data/                    # Capa de Datos
│   ├── models/             # Modelos de datos
│   ├── datasources/        # Fuentes de datos (local/remote)
│   └── repositories/       # Implementación de repositorios
│
└── presentation/            # Capa de Presentación
    ├── cubit/              # Gestión de estado (Cubit)
    ├── screens/            # Pantallas
    └── widgets/            # Widgets reutilizables
        ├── common/         # Widgets comunes
        └── barber/         # Widgets específicos
```

## 🚀 Características

- ✅ **Clean Architecture** - Separación clara de responsabilidades
- ✅ **BLoC Pattern (Cubit)** - Gestión de estado reactiva
- ✅ **Widgets Reutilizables** - Código escalable y mantenible
- ✅ **Inyección de Dependencias** - GetIt para gestión de dependencias
- ✅ **Navegación** - GoRouter para routing declarativo
- ✅ **Tema Personalizado** - Diseño dark con paleta dorada

## 📦 Dependencias Principales

- `flutter_bloc` - Gestión de estado
- `get_it` - Inyección de dependencias
- `go_router` - Navegación
- `dio` - Cliente HTTP
- `shared_preferences` - Almacenamiento local
- `cached_network_image` - Carga eficiente de imágenes
- `shimmer` - Efectos de carga

## 🛠️ Instalación

1. Instalar dependencias:
```bash
flutter pub get
```

2. Ejecutar la aplicación:
```bash
flutter run
```

## 📱 Funcionalidades

### Autenticación
- Login con email y contraseña
- Registro de nuevos usuarios
- Manejo de sesiones

### Barberos
- Listado de barberos disponibles
- Búsqueda de barberos
- Filtrado por categoría
- Perfil detallado de cada barbero

### Citas
- Reserva de citas
- Historial de citas
- Calendario de disponibilidad
- Métodos de pago

## 🎨 Diseño

La aplicación utiliza un diseño dark con:
- **Color Primario**: Dorado (#C9A961)
- **Fondo**: Negro (#121212)
- **Tarjetas**: Gris oscuro (#1A1A1A)

## 🔧 Desarrollo

### Agregar una nueva feature

1. Crear entidad en `domain/entities/`
2. Crear interfaz de repositorio en `domain/repositories/`
3. Crear casos de uso en `domain/usecases/`
4. Implementar modelo en `data/models/`
5. Implementar datasource en `data/datasources/`
6. Implementar repositorio en `data/repositories/`
7. Crear Cubit en `presentation/cubit/`
8. Crear pantalla en `presentation/screens/`
9. Registrar dependencias en `core/injection/injection.dart`
10. Agregar ruta en `core/routing/app_router.dart`

### Widgets Reutilizables

Todos los widgets comunes están en `presentation/widgets/common/`:
- `AppButton` - Botón con diferentes variantes
- `AppCard` - Tarjeta con estilo consistente
- `AppTextField` - Campo de texto con validación
- `AppAvatar` - Avatar con fallback
- `AppBadge` - Badge con diferentes tipos
- `LoadingWidget` - Indicadores de carga

## 📝 Mejores Prácticas

1. **Separación de Responsabilidades**: Cada capa tiene su responsabilidad específica
2. **Reutilización**: Widgets comunes para evitar duplicación
3. **Inmutabilidad**: Estados inmutables con Equatable
4. **Manejo de Errores**: Failures tipados para mejor manejo
5. **Testing**: Estructura preparada para tests unitarios y de widgets

## 🌐 Integración con Backend

La aplicación está integrada con un backend Node.js + TypeScript + Express + Prisma.

### Configuración de la URL del Backend

Edita `lib/core/constants/app_constants.dart` para configurar la URL según tu entorno:

```dart
static String get baseUrl {
  // Android Emulador
  return 'http://10.0.2.2:3000';
  
  // iOS Simulador o Web
  // return 'http://localhost:3000';
  
  // Dispositivo físico (cambia por tu IP)
  // return 'http://TU_IP_LOCAL:3000';
}
```

### Backend

El backend está en la carpeta `backend/`. Ver [backend/README.md](backend/README.md) para más detalles.

## 🚧 Próximas Mejoras

- [ ] Pantallas Discover, History y Profile
- [x] Integración con API real
- [ ] Notificaciones push
- [ ] Mapa de ubicaciones
- [ ] Sistema de pagos
- [ ] Calificación y reseñas

## 👨‍💻 Autor

Desarrollado siguiendo las mejores prácticas de Flutter y Clean Architecture.
