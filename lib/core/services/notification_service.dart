import 'dart:io';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../injection/injection.dart';
import '../routing/app_router.dart';
import '../../domain/repositories/fcm_token_repository.dart';

/// Handler para notificaciones en segundo plano (debe ser una función top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final logger = Logger();
  logger.i('Handling background message: ${message.messageId}');
  logger.i('Notification data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  String? _fcmToken;
  bool _initialized = false;

  /// Obtiene el token FCM actual
  String? get fcmToken => _fcmToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) {
      _logger.w('NotificationService already initialized');
      return;
    }

    try {
      // Inicializar Firebase si no está inicializado
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Configurar notificaciones locales
      await _initializeLocalNotifications();

      // Solicitar permisos
      await _requestPermissions();

      // Configurar handlers
      await _setupMessageHandlers();

      // Obtener token FCM
      await _getFCMToken();

      _initialized = true;
      _logger.i('✅ NotificationService initialized successfully');
    } catch (e) {
      _logger.e('❌ Error initializing NotificationService: $e');
      rethrow;
    }
  }

  /// Inicializa sin solicitar permisos (útil para no solicitar al iniciar)
  Future<void> initializeWithoutPermissionRequest() async {
    if (_initialized) {
      _logger.w('NotificationService already initialized');
      return;
    }

    try {
      // Inicializar Firebase si no está inicializado
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Configurar notificaciones locales
      await _initializeLocalNotifications();

      // NO solicitar permisos aquí - se hará cuando sea necesario

      // Configurar handlers
      await _setupMessageHandlers();

      // Intentar obtener token FCM (puede fallar si no hay permiso, pero no es crítico)
      try {
        await _getFCMToken();
      } catch (e) {
        _logger.w('⚠️ Could not get FCM token (permission may be needed): $e');
      }

      _initialized = true;
      _logger.i(
        '✅ NotificationService initialized (without permission request)',
      );
    } catch (e) {
      _logger.e('❌ Error initializing NotificationService: $e');
      rethrow;
    }
  }

  /// Inicializa las notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones para Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'appointments', // id
        'Citas y Notificaciones', // name
        description: 'Notificaciones sobre citas y actualizaciones',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Verifica si el permiso de notificaciones está concedido
  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      // Verificar usando permission_handler (más confiable)
      final status = await Permission.notification.status;
      _logger.i('📱 Notification permission status: $status');
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  /// Solicita permisos para notificaciones (versión mejorada)
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        _logger.i(
          '📱 iOS notification permission status: ${settings.authorizationStatus}',
        );
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } else if (Platform.isAndroid) {
        // Verificar primero si ya tiene el permiso
        final hasPermission = await hasNotificationPermission();
        if (hasPermission) {
          _logger.i('✅ Notification permission already granted');
          return true;
        }

        _logger.i('🔔 Requesting notification permission...');

        // Método 1: Usar permission_handler (más confiable)
        try {
          final status = await Permission.notification.request();
          _logger.i('📱 Permission handler result: $status');

          if (status.isGranted) {
            _logger.i(
              '✅ Notification permission granted via permission_handler',
            );
            return true;
          } else if (status.isPermanentlyDenied) {
            _logger.w('⚠️ Notification permission permanently denied');
            return false;
          }
        } catch (e) {
          _logger.w('⚠️ Error using permission_handler: $e');
        }

        // Método 2: Usar flutter_local_notifications como alternativa
        try {
          final androidImplementation = _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

          if (androidImplementation != null) {
            // Verificar si las notificaciones están habilitadas
            final areEnabled = await androidImplementation
                .areNotificationsEnabled();
            _logger.i('📱 Are notifications enabled: $areEnabled');

            if (areEnabled == true) {
              _logger.i('✅ Notifications already enabled');
              return true;
            }

            // Solicitar permiso
            final granted = await androidImplementation
                .requestNotificationsPermission();
            _logger.i('📱 Local notifications permission result: $granted');

            if (granted == true) {
              _logger.i(
                '✅ Notification permission granted via local notifications',
              );
              return true;
            }
          }
        } catch (e) {
          _logger.w('⚠️ Error using flutter_local_notifications: $e');
        }

        _logger.w('⚠️ Could not request notification permission');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error requesting notification permission: $e');
      return false;
    }
    return false;
  }

  /// Método público para solicitar permisos (útil para solicitar más tarde)
  Future<bool> requestPermissions() async {
    return await _requestPermissions();
  }

  /// Configura los handlers de mensajes
  Future<void> _setupMessageHandlers() async {
    // Handler para mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('🔔 Received foreground message: ${message.messageId}');
      _logger.i('🔔 Message title: ${message.notification?.title}');
      _logger.i('🔔 Message body: ${message.notification?.body}');
      _handleForegroundMessage(message);
    });

    // Handler para cuando se toca una notificación y la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('Notification opened app: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handler para cuando se toca una notificación y la app está cerrada
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _logger.i('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }

    // Configurar handler para segundo plano
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Maneja mensajes en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.i('📨 Handling foreground message: ${message.messageId}');
    _logger.i('📨 Message data: ${message.data}');
    _logger.i(
      '📨 Message notification: ${message.notification?.title} - ${message.notification?.body}',
    );

    final notification = message.notification;
    if (notification == null) {
      _logger.w('⚠️ Message has no notification payload');
      return;
    }

    _logger.i(
      '📱 Showing local notification: ${notification.title} - ${notification.body}',
    );

    // Mostrar notificación local
    try {
      // Convertir el Map de data a JSON string para el payload
      final payloadJson = jsonEncode(message.data);

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointments',
            'Citas y Notificaciones',
            channelDescription: 'Notificaciones sobre citas y actualizaciones',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payloadJson,
      );
      _logger.i('✅ Local notification shown successfully');
    } catch (e) {
      _logger.e('❌ Error showing local notification: $e');
    }
  }

  /// Maneja cuando se toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    _logger.i('🔔 Notification tapped with data: $data');

    // Navegar a detalles de cita si viene appointmentId
    if (data.containsKey('appointmentId')) {
      final appointmentId = data['appointmentId'] as String?;
      if (appointmentId != null && appointmentId.isNotEmpty) {
        _logger.i('📍 Navigating to appointment: $appointmentId');
        // Usar GoRouter para navegar
        appRouter.go('/appointment/$appointmentId');
      } else {
        _logger.w('⚠️ appointmentId is empty or null');
      }
    } else {
      _logger.i(
        'ℹ️ No appointmentId in notification data, skipping navigation',
      );
    }
  }

  /// Callback cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('🔔 Local notification tapped: ${response.payload}');

    // El payload es un JSON string que representa el Map de data
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final payload = response.payload!;
        _logger.i('📦 Parsing payload: $payload');

        // Parsear el JSON string a Map
        final data = jsonDecode(payload) as Map<String, dynamic>;

        // Extraer appointmentId del Map
        if (data.containsKey('appointmentId')) {
          final appointmentId = data['appointmentId'] as String?;
          if (appointmentId != null && appointmentId.isNotEmpty) {
            _logger.i(
              '📍 Navigating to appointment from local notification: $appointmentId',
            );
            appRouter.go('/appointment/$appointmentId');
            return;
          } else {
            _logger.w('⚠️ appointmentId is empty or null in payload');
          }
        } else {
          _logger.i(
            'ℹ️ No appointmentId in notification payload, skipping navigation',
          );
        }
      } catch (e) {
        _logger.e('❌ Error parsing notification payload: $e');
        // Intentar parseo alternativo si el JSON falla (por compatibilidad con formato anterior)
        try {
          final payload = response.payload!;
          final appointmentIdMatch = RegExp(
            r'"appointmentId"\s*:\s*"([^"]+)"',
          ).firstMatch(payload);
          if (appointmentIdMatch != null) {
            final appointmentId = appointmentIdMatch.group(1);
            if (appointmentId != null && appointmentId.isNotEmpty) {
              _logger.i(
                '📍 Navigating to appointment (fallback parsing): $appointmentId',
              );
              appRouter.go('/appointment/$appointmentId');
              return;
            }
          }
        } catch (e2) {
          _logger.e('❌ Error in fallback parsing: $e2');
        }
      }
    } else {
      _logger.i('ℹ️ No payload in local notification, skipping navigation');
    }
  }

  /// Obtiene el token FCM del dispositivo
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i('FCM Token obtained: ${_fcmToken?.substring(0, 20)}...');

      // Escuchar cambios en el token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
        _fcmToken = newToken;
        // Actualizar el token en el backend
        _updateTokenInBackend(newToken);
      });

      return _fcmToken;
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  /// Obtiene el token FCM (método público)
  Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;
    return await _getFCMToken();
  }

  /// Elimina el token FCM (útil para logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      _logger.i('FCM Token deleted');
    } catch (e) {
      _logger.e('Error deleting FCM token: $e');
    }
  }

  /// Suscribe a un tema (opcional, para notificaciones por temas)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic $topic: $e');
    }
  }

  /// Cancela suscripción a un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Actualiza el token FCM en el backend cuando se refresca
  Future<void> _updateTokenInBackend(String newToken) async {
    try {
      // Obtener el repositorio de FCM tokens usando GetIt
      final fcmTokenRepository = sl<FcmTokenRepository>();
      final deviceType = Platform.isAndroid ? 'android' : 'ios';

      _logger.i(
        '📤 Updating FCM token in backend: ${newToken.substring(0, 20)}... (deviceType: $deviceType)',
      );

      final result = await fcmTokenRepository.registerToken(
        token: newToken,
        deviceType: deviceType,
      );

      result.fold(
        (failure) {
          _logger.e(
            '❌ Error updating FCM token in backend: ${failure.message}',
          );
        },
        (_) {
          _logger.i('✅ FCM token updated successfully in backend');
        },
      );
    } catch (e) {
      // No lanzar error, solo loggear - las notificaciones no son críticas
      _logger.e('❌ Unexpected error updating FCM token in backend: $e');
    }
  }
}
