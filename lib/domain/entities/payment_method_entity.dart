import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final bool isActive;
  final String? type; // Tipo de método: 'PAGO_MOVIL', 'BINANCE', 'TRANSFERENCIA', etc.
  final Map<String, dynamic>? config; // Datos específicos del método (banco, teléfono, wallet, etc.)

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    this.icon,
    this.isActive = true,
    this.type,
    this.config,
  });

  @override
  List<Object?> get props => [id, name, icon, isActive, type, config];
}

