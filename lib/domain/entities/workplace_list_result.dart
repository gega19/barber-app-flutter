import 'package:equatable/equatable.dart';
import 'workplace_entity.dart';

/// Resultado paginado de lista de barberías con total
class WorkplaceListResult extends Equatable {
  final List<WorkplaceEntity> workplaces;
  final int total;

  const WorkplaceListResult({required this.workplaces, required this.total});

  @override
  List<Object?> get props => [workplaces, total];
}
