import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String? barberId;
  final String? workplaceId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserEntity user;

  const ReviewEntity({
    required this.id,
    required this.userId,
    this.barberId,
    this.workplaceId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        barberId,
        workplaceId,
        rating,
        comment,
        createdAt,
        updatedAt,
        user,
      ];
}

