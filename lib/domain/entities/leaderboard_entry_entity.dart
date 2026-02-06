import 'package:equatable/equatable.dart';

class LeaderboardEntryEntity extends Equatable {
  final int position;
  final String barberId;
  final String barberName;
  final String barberImage;
  final int points;

  const LeaderboardEntryEntity({
    required this.position,
    required this.barberId,
    required this.barberName,
    required this.barberImage,
    required this.points,
  });

  @override
  List<Object?> get props => [
    position,
    barberId,
    barberName,
    barberImage,
    points,
  ];
}
