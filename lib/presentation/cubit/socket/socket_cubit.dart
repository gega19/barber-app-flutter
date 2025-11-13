import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/socket_service.dart';
import 'socket_state.dart';

class SocketCubit extends Cubit<SocketState> {
  final SocketService _socketService;

  SocketCubit(this._socketService) : super(const SocketInitial()) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.onConnect = () {
      emit(const SocketConnected());
    };

    _socketService.onDisconnect = (reason) {
      emit(SocketDisconnected(reason));
    };

    _socketService.onError = (error) {
      emit(SocketError(error));
    };
  }

  Future<void> connect() async {
    emit(const SocketConnecting());
    try {
      await _socketService.connect();
    } catch (e) {
      emit(SocketError(e.toString()));
    }
  }

  void disconnect() {
    _socketService.disconnect();
    emit(const SocketDisconnected('User disconnected'));
  }

  @override
  Future<void> close() {
    _socketService.disconnect();
    return super.close();
  }
}
