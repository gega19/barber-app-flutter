import '../../domain/entities/review_entity.dart';
import 'user_model.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    super.barberId,
    super.workplaceId,
    required super.rating,
    super.comment,
    required super.createdAt,
    required super.updatedAt,
    required super.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      barberId: json['barberId'] as String?,
      workplaceId: json['workplaceId'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      if (barberId != null) 'barberId': barberId,
      if (workplaceId != null) 'workplaceId': workplaceId,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': (user as UserModel).toJson(),
    };
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      userId: entity.userId,
      barberId: entity.barberId,
      workplaceId: entity.workplaceId,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      user: entity.user,
    );
  }
}

