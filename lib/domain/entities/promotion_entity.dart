import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String code;
  final double? discount;
  final double? discountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? image;
  final PromotionBarber? barber;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    this.discount,
    this.discountAmount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.image,
    this.barber,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        code,
        discount,
        discountAmount,
        validFrom,
        validUntil,
        isActive,
        image,
        barber,
      ];
}

class PromotionBarber extends Equatable {
  final String id;
  final String name;
  final String email;

  const PromotionBarber({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}

