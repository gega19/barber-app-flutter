import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.name,
    super.icon,
    super.isActive = true,
    super.type,
    super.config,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      type: json['type'] as String?,
      config: json['config'] != null 
          ? Map<String, dynamic>.from(json['config'] as Map) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (icon != null) 'icon': icon,
      'isActive': isActive,
      if (type != null) 'type': type,
      if (config != null) 'config': config,
    };
  }

  factory PaymentMethodModel.fromEntity(PaymentMethodEntity entity) {
    return PaymentMethodModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      isActive: entity.isActive,
      type: entity.type,
      config: entity.config,
    );
  }
}

