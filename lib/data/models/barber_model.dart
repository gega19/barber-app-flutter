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
    super.slug,
    super.latitude,
    super.longitude,
    super.instagramUrl,
    super.tiktokUrl,
    super.phone,
    super.country,
    super.timezone,
    super.priceCurrencyCode,
    super.priceCurrencySymbol,
    super.isLastWinner = false,
    int top1Count = 0,
    int top2Count = 0,
    int top3Count = 0,
  }) : _workplaceId = workplaceId,
       super(top1Count: top1Count, top2Count: top2Count, top3Count: top3Count);

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      image: json['avatar'] as String? ?? json['image'] as String?,
      avatarSeed: json['avatarSeed'] as String?,
      specialty: json['specialty'] as String? ?? '',
      experience: (json['experienceYears'] as int?)?.toString() ?? '0',
      distance: json['distance'] as String? ?? '',
      workplaceId: json['workplaceId'] as String?,
      slug: json['slug'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      instagramUrl: json['instagramUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      priceCurrencyCode: json['priceCurrencyCode'] as String?,
      priceCurrencySymbol: json['priceCurrencySymbol'] as String?,
      isLastWinner: json['isLastWinner'] as bool? ?? false,
      top1Count: (json['top1Count'] as num?)?.toInt() ?? 0,
      top2Count: (json['top2Count'] as num?)?.toInt() ?? 0,
      top3Count: (json['top3Count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String? get workplaceId => _workplaceId;
  String? get serviceType => null; // Will be extracted from JSON if needed
  Map<String, dynamic>? get workplaceRef =>
      null; // Will be extracted from JSON if needed

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
      'phone': phone,
      'country': country,
      'timezone': timezone,
      'priceCurrencyCode': priceCurrencyCode,
      'priceCurrencySymbol': priceCurrencySymbol,
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
      slug: entity.slug,
      latitude: entity.latitude,
      longitude: entity.longitude,
      instagramUrl: entity.instagramUrl,
      tiktokUrl: entity.tiktokUrl,
      phone: entity.phone,
      country: entity.country,
      timezone: entity.timezone,
      priceCurrencyCode: entity.priceCurrencyCode,
      priceCurrencySymbol: entity.priceCurrencySymbol,
      isLastWinner: entity.isLastWinner,
      top1Count: entity.top1Count,
      top2Count: entity.top2Count,
      top3Count: entity.top3Count,
    );
  }
}
