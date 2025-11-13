import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_it/get_it.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/local/local_storage.dart';
import '../utils/logger.dart';

enum SocketConnectionStatus { disconnected, connecting, connected, error }

class SocketService {
  IO.Socket? _socket;
  SocketConnectionStatus _status = SocketConnectionStatus.disconnected;
  final LocalStorage _localStorage = GetIt.instance<LocalStorage>();

  SocketConnectionStatus get status => _status;
  bool get isConnected => _status == SocketConnectionStatus.connected;

  // Callbacks para eventos
  Function()? onConnect;
  Function(String)? onDisconnect;
  Function(String)? onError;

  /// Conecta al servidor Socket.IO
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      appLogger.i('Socket already connected');
      return;
    }

    try {
      _status = SocketConnectionStatus.connecting;

      // Obtener token de autenticación
      final token = await _localStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      // Crear socket con autenticación
      _socket = IO.io(
        AppConstants.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .setAuth({'token': token})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(20000)
            .build(),
      );

      _setupEventHandlers();

      appLogger.i('Socket connecting to: ${AppConstants.baseUrl}');
    } catch (e) {
      _status = SocketConnectionStatus.error;
      appLogger.e('Error connecting socket: $e');
      onError?.call(e.toString());
      rethrow;
    }
  }

  /// Configura los handlers de eventos del socket
  void _setupEventHandlers() {
    if (_socket == null) return;

    // Evento de conexión
    _socket!.onConnect((_) {
      _status = SocketConnectionStatus.connected;
      appLogger.i('✅ Socket connected');
      onConnect?.call();
    });

    // Evento de desconexión
    _socket!.onDisconnect((reason) {
      _status = SocketConnectionStatus.disconnected;
      appLogger.w('👋 Socket disconnected: $reason');
      onDisconnect?.call(reason);
    });

    // Evento de error
    _socket!.onError((error) {
      _status = SocketConnectionStatus.error;
      appLogger.e('❌ Socket error: $error');
      onError?.call(error.toString());
    });

    // Evento de reconexión
    _socket!.onReconnect((attempt) {
      appLogger.i('🔄 Socket reconnecting (attempt $attempt)');
      _status = SocketConnectionStatus.connecting;
    });
  }

  /// Desconecta el socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _status = SocketConnectionStatus.disconnected;
      appLogger.i('Socket disconnected and disposed');
    }
  }

  /// Reautentica con un nuevo token
  Future<void> reauthenticate(String newToken) async {
    disconnect();
    await _localStorage.saveToken(newToken);
    await connect();
  }
}
