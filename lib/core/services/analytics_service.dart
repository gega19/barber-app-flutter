import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../utils/logger.dart';

/// Servicio de analytics con batch processing y queue local para offline
class AnalyticsService {
  static const int _batchSize = 20; // Enviar cada 20 eventos
  static const Duration _batchTimeout = Duration(
    minutes: 5,
  ); // O cada 5 minutos
  static const int _maxQueueSize = 1000; // Máximo de eventos en cola
  static const String _eventsQueueKey = 'analytics_events_queue';
  static const String _sessionIdKey = 'analytics_session_id';

  final Dio _dio;
  final SharedPreferences _prefs;
  final LocalStorage _localStorage;
  final List<Map<String, dynamic>> _eventQueue = [];
  Timer? _batchTimer;
  String? _sessionId;
  bool _isInitialized = false;

  // Flag para habilitar/deshabilitar analytics (útil para testing)
  static bool _isEnabled = true;

  /// Habilita o deshabilita el tracking de analytics
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    appLogger.i('Analytics ${enabled ? "enabled" : "disabled"}');
  }

  /// Verifica si el analytics está habilitado
  /// En modo debug, no se envían eventos a menos que se fuerce
  bool get isEnabled => _isEnabled;

  /// Verifica si se debe enviar el evento (no en dev a menos que se fuerce o esté habilitado)
  bool _shouldSendEvent({bool forceSend = false}) {
    if (!_isEnabled) return false;
    if (kDebugMode && !forceSend && !AppConstants.enableAnalyticsInDev) {
      return false;
    }
    return true;
  }

  AnalyticsService({
    required Dio dio,
    required SharedPreferences prefs,
    required LocalStorage localStorage,
  }) : _dio = dio,
       _prefs = prefs,
       _localStorage = localStorage;

  /// Inicializa el servicio de analytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Obtener o crear sessionId
    _sessionId = _prefs.getString(_sessionIdKey);
    if (_sessionId == null || _sessionId!.isEmpty) {
      _sessionId = const Uuid().v4();
      await _prefs.setString(_sessionIdKey, _sessionId!);
    }

    // Cargar eventos pendientes del almacenamiento local
    await _loadStoredEvents();

    // Intentar sincronizar eventos pendientes
    await syncPendingEvents();

    _isInitialized = true;
    appLogger.i('✅ AnalyticsService initialized');
  }

  /// Registra un evento de analytics
  /// Los eventos se acumulan y se envían en batch
  /// En modo desarrollo, solo se loggean los eventos (no se envían)
  Future<void> trackEvent({
    required String eventName,
    required String eventType,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? metadata,
    bool forceSend = false, // Para forzar envío incluso en dev
  }) async {
    // En desarrollo, solo loggear (no enviar) a menos que se fuerce
    if (!_shouldSendEvent(forceSend: forceSend)) {
      appLogger.d('📊 Event tracked (not sent in dev): $eventName');
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Obtener userId si está disponible
      String? userId;
      try {
        final userDataJson = await _localStorage.getUserData();
        if (userDataJson != null && userDataJson.isNotEmpty) {
          final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
          userId = userData['id'] as String?;
        }
      } catch (e) {
        // Si no hay usuario o hay error, continuar sin userId
      }

      // Obtener metadata del dispositivo
      final deviceMetadata = {
        ...?metadata,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _sessionId,
      };

      final event = {
        'eventType': eventType,
        'eventName': eventName,
        'platform': 'app',
        'userId': userId,
        'sessionId': _sessionId,
        'properties': properties ?? {},
        'metadata': deviceMetadata,
      };

      // Agregar a la cola en memoria
      _eventQueue.add(event);

      // Si llegamos al límite, enviar inmediatamente
      if (_eventQueue.length >= _batchSize) {
        await _flushEvents();
      } else {
        // Si no hay timer, crear uno
        _batchTimer ??= Timer(_batchTimeout, () => _flushEvents());
      }

      // Guardar en almacenamiento local para persistencia
      await _saveEventsToLocal();
    } catch (e) {
      appLogger.e('Error tracking event: $e');
      // No lanzar error para no interrumpir el flujo principal
    }
  }

  /// Registra una visualización de pantalla
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      eventName: 'screen_view',
      eventType: 'user_action',
      properties: {'screenName': screenName, ...?properties},
    );
  }

  /// Trackea un error con información detallada
  /// Incluye stack trace, contexto, request/response data, y severidad
  /// En desarrollo, solo se loggean los errores (no se envían)
  Future<void> trackError({
    required String errorName,
    required String
    errorType, // 'api_error', 'network_error', 'app_error', etc.
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String severity = 'medium', // 'low', 'medium', 'high', 'critical'
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
    bool forceSend = false, // Para forzar envío incluso en dev
  }) async {
    // En desarrollo, solo loggear (no enviar) a menos que se fuerce
    if (!_shouldSendEvent(forceSend: forceSend)) {
      appLogger.e(
        '🔴 Error tracked (not sent in dev): $errorName',
        error: error,
        stackTrace: stackTrace,
      );
      if (context != null) {
        appLogger.d('   Context: $context');
      }
      if (requestData != null) {
        appLogger.d('   Request: $requestData');
      }
      if (responseData != null) {
        appLogger.d('   Response: $responseData');
      }
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Obtener userId si está disponible
      String? userId;
      try {
        final userDataJson = await _localStorage.getUserData();
        if (userDataJson != null && userDataJson.isNotEmpty) {
          final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
          userId = userData['id'] as String?;
        }
      } catch (e) {
        // Si no hay usuario o hay error, continuar sin userId
      }

      // Preparar propiedades del error con información detallada
      final errorProperties = {
        'errorName': errorName,
        'errorType': errorType,
        'errorMessage': error.toString(),
        'errorClass': error.runtimeType.toString(),
        'severity': severity,
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
        if (context != null) ...context,
        if (requestData != null) 'requestData': requestData,
        if (responseData != null) 'responseData': responseData,
      };

      // Obtener metadata del dispositivo
      final deviceMetadata = {
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _sessionId,
        'errorClass': error.runtimeType.toString(),
      };

      final event = {
        'eventType': 'error',
        'eventName': errorName,
        'platform': 'app',
        'userId': userId,
        'sessionId': _sessionId,
        'properties': errorProperties,
        'metadata': deviceMetadata,
      };

      // Agregar a la cola en memoria
      _eventQueue.add(event);

      // Si llegamos al límite, enviar inmediatamente
      if (_eventQueue.length >= _batchSize) {
        await _flushEvents();
      } else {
        // Si no hay timer, crear uno
        _batchTimer ??= Timer(_batchTimeout, () => _flushEvents());
      }

      // Guardar en almacenamiento local para persistencia
      await _saveEventsToLocal();
    } catch (e) {
      appLogger.e('Error tracking error event: $e');
      // No lanzar error para no interrumpir el flujo principal
    }
  }

  /// Envía todos los eventos pendientes inmediatamente
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;

    final eventsToSend = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();
    _batchTimer?.cancel();
    _batchTimer = null;

    try {
      await _dio.post(
        '${AppConstants.baseUrl}/api/analytics/track-batch',
        data: {'events': eventsToSend},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      appLogger.d('✅ Sent ${eventsToSend.length} analytics events');

      // Si se enviaron correctamente, limpiar del almacenamiento local
      await _prefs.remove(_eventsQueueKey);
    } catch (e) {
      appLogger.e('❌ Failed to send analytics events: $e');

      // Si falla, guardar en local storage para reintentar después
      await _saveEventsToLocal(eventsToSend);

      // Re-agregar eventos a la cola para reintentar
      _eventQueue.addAll(eventsToSend);
    }
  }

  /// Guarda eventos en almacenamiento local
  Future<void> _saveEventsToLocal([List<Map<String, dynamic>>? events]) async {
    try {
      final eventsToSave = events ?? _eventQueue;
      if (eventsToSave.isEmpty) return;

      // Obtener eventos existentes
      final existingEventsJson = _prefs.getString(_eventsQueueKey);
      final existingEvents = existingEventsJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(existingEventsJson))
          : <Map<String, dynamic>>[];

      // Combinar con nuevos eventos
      existingEvents.addAll(eventsToSave);

      // Mantener máximo de eventos en cola
      if (existingEvents.length > _maxQueueSize) {
        existingEvents.removeRange(0, existingEvents.length - _maxQueueSize);
      }

      // Guardar
      await _prefs.setString(_eventsQueueKey, jsonEncode(existingEvents));
    } catch (e) {
      appLogger.e('Error saving events to local storage: $e');
    }
  }

  /// Carga eventos almacenados localmente
  Future<void> _loadStoredEvents() async {
    try {
      final eventsJson = _prefs.getString(_eventsQueueKey);
      if (eventsJson != null && eventsJson.isNotEmpty) {
        final storedEvents = List<Map<String, dynamic>>.from(
          jsonDecode(eventsJson),
        );
        _eventQueue.addAll(storedEvents);
        appLogger.d('Loaded ${storedEvents.length} stored events');
      }
    } catch (e) {
      appLogger.e('Error loading stored events: $e');
    }
  }

  /// Sincroniza eventos pendientes (útil cuando se recupera conexión)
  Future<void> syncPendingEvents() async {
    if (_eventQueue.isEmpty) {
      await _loadStoredEvents();
    }

    if (_eventQueue.isNotEmpty) {
      await _flushEvents();
    }
  }

  /// Genera un nuevo sessionId (útil cuando el usuario inicia sesión)
  Future<void> startNewSession() async {
    _sessionId = const Uuid().v4();
    await _prefs.setString(_sessionIdKey, _sessionId!);
    appLogger.d('Started new analytics session: $_sessionId');
  }

  /// Limpia todos los eventos pendientes (útil para testing o logout)
  Future<void> clearEvents() async {
    _eventQueue.clear();
    _batchTimer?.cancel();
    _batchTimer = null;
    await _prefs.remove(_eventsQueueKey);
  }

  /// Cierra el servicio y envía eventos pendientes
  Future<void> dispose() async {
    _batchTimer?.cancel();
    await _flushEvents();
  }
}
