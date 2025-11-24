import '../../domain/entities/barber_entity.dart';

/// Modelo de barbero para la capa de datos
class BarberModel extends BarberEntity {
  final String? _workplaceId;

  const BarberModel({
    required super.id,
    required super.name,
    required super.rating,
    required super.reviews,
    required super.price,
    required super.location,
    super.image,
    super.avatarSeed,
    required super.specialty,
    required super.experience,
    required super.distance,
    String? workplaceId,
  }) : _workplaceId = workplaceId;

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String,
      image: json['avatar'] as String? ?? json['image'] as String?,
      avatarSeed: json['avatarSeed'] as String?,
      specialty: json['specialty'] as String,
      experience: (json['experienceYears'] as int?)?.toString() ?? '0',
      distance: json['distance'] as String? ?? '',
      workplaceId: json['workplaceId'] as String?,
    );
  }

  @override
  String? get workplaceId => _workplaceId;
  String? get serviceType => null; // Will be extracted from JSON if needed
  Map<String, dynamic>? get workplaceRef => null; // Will be extracted from JSON if needed

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'reviews': reviews,
      'price': price,
      'location': location,
      'image': image,
      'avatarSeed': avatarSeed,
      'specialty': specialty,
      'experience': experience,
      'distance': distance,
    };
  }

  factory BarberModel.fromEntity(BarberEntity entity) {
    return BarberModel(
      id: entity.id,
      name: entity.name,
      rating: entity.rating,
      reviews: entity.reviews,
      price: entity.price,
      location: entity.location,
      image: entity.image,
      avatarSeed: entity.avatarSeed,
      specialty: entity.specialty,
      experience: entity.experience,
      distance: entity.distance,
      workplaceId: entity.workplaceId,
    );
  }
}

