import 'package:equatable/equatable.dart';
import 'barber_entity.dart';

/// Resultado paginado de lista de barberos con total
class BarberListResult extends Equatable {
  final List<BarberEntity> barbers;
  final int total;

  const BarberListResult({required this.barbers, required this.total});

  @override
  List<Object?> get props => [barbers, total];
}
