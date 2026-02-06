import 'package:equatable/equatable.dart';
import 'leaderboard_entry_entity.dart';

/// Resultado paginado del leaderboard de competencia
class LeaderboardResultEntity extends Equatable {
  final List<LeaderboardEntryEntity> entries;
  final int total;

  const LeaderboardResultEntity({required this.entries, required this.total});

  @override
  List<Object?> get props => [entries, total];
}
