import 'package:equatable/equatable.dart';

abstract class SocketState extends Equatable {
  const SocketState();

  @override
  List<Object?> get props => [];
}

class SocketInitial extends SocketState {
  const SocketInitial();
}

class SocketConnecting extends SocketState {
  const SocketConnecting();
}

class SocketConnected extends SocketState {
  const SocketConnected();
}

class SocketDisconnected extends SocketState {
  final String reason;

  const SocketDisconnected(this.reason);

  @override
  List<Object> get props => [reason];
}

class SocketError extends SocketState {
  final String message;

  const SocketError(this.message);

  @override
  List<Object> get props => [message];
}
