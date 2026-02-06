import 'package:equatable/equatable.dart';

class CompetitionPeriodEntity extends Equatable {
  final String id;
  final String? name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? winnerBarberId;
  final String? winnerName;
  final String? prize;
  final DateTime? closedAt;

  const CompetitionPeriodEntity({
    required this.id,
    this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.winnerBarberId,
    this.winnerName,
    this.prize,
    this.closedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    startDate,
    endDate,
    status,
    winnerBarberId,
    winnerName,
    prize,
    closedAt,
  ];
}
