import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

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

  /// Inicializa las notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Solicita permisos para notificaciones
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _logger.i('iOS notification permission status: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // Android 13+ requiere permisos explícitos
      final androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        _logger.i('Android notification permission granted: $granted');
      }
    }
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
    _logger.i('📨 Message notification: ${message.notification?.title} - ${message.notification?.body}');
    
    final notification = message.notification;
    if (notification == null) {
      _logger.w('⚠️ Message has no notification payload');
      return;
    }

    _logger.i('📱 Showing local notification: ${notification.title} - ${notification.body}');

    // Mostrar notificación local
    try {
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
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
      _logger.i('✅ Local notification shown successfully');
    } catch (e) {
      _logger.e('❌ Error showing local notification: $e');
    }
  }

  /// Maneja cuando se toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    // Aquí puedes navegar a una pantalla específica basada en message.data
    final data = message.data;
    _logger.i('Notification tapped with data: $data');

    // Ejemplo: navegar a detalles de cita si viene appointmentId
    // if (data.containsKey('appointmentId')) {
    //   // Navigator.push(...)
    // }
  }

  /// Callback cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Local notification tapped: ${response.payload}');
    // Aquí puedes manejar la navegación
  }

  /// Obtiene el token FCM del dispositivo
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i('FCM Token obtained: ${_fcmToken?.substring(0, 20)}...');

      // Escuchar cambios en el token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token refreshed: ${newToken.substring(0, 20)}...');
        _fcmToken = newToken;
        // Aquí deberías actualizar el token en el backend
        // _updateTokenInBackend(newToken);
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
}

