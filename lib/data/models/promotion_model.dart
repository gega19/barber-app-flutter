import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.code,
    super.discount,
    super.discountAmount,
    required super.validFrom,
    required super.validUntil,
    required super.isActive,
    super.image,
    super.barber,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    PromotionBarber? barber;
    if (json['barber'] != null) {
      final barberData = json['barber'] as Map<String, dynamic>;
      barber = PromotionBarber(
        id: barberData['id'] as String,
        name: barberData['name'] as String,
        email: barberData['email'] as String,
      );
    }

    return PromotionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      code: json['code'] as String,
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      discountAmount: json['discountAmount'] != null ? (json['discountAmount'] as num).toDouble() : null,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      isActive: json['isActive'] as bool,
      image: json['image'] as String?,
      barber: barber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'discount': discount,
      'discountAmount': discountAmount,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'isActive': isActive,
      'image': image,
      'barber': barber != null
          ? {
              'id': barber!.id,
              'name': barber!.name,
              'email': barber!.email,
            }
          : null,
    };
  }

  factory PromotionModel.fromEntity(PromotionEntity entity) {
    return PromotionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      code: entity.code,
      discount: entity.discount,
      discountAmount: entity.discountAmount,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
      isActive: entity.isActive,
      image: entity.image,
      barber: entity.barber,
    );
  }
}

