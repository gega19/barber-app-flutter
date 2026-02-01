import 'package:equatable/equatable.dart';

/// Entidad de barbero del dominio
class BarberEntity extends Equatable {
  final String id;
  final String name;
  final double rating;
  final int reviews;
  final double price;
  final String location;
  final String? image;
  final String? avatarSeed;
  final String specialty;
  final String experience;
  final String distance;
  final String? workplaceId;
  final String? slug;
  final double? latitude;
  final double? longitude;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? phone;

  const BarberEntity({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.location,
    this.image,
    this.avatarSeed,
    required this.specialty,
    required this.experience,
    required this.distance,
    this.workplaceId,
    this.slug,
    this.latitude,
    this.longitude,
    this.instagramUrl,
    this.tiktokUrl,
    this.phone,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    rating,
    reviews,
    price,
    location,
    image,
    avatarSeed,
    specialty,
    experience,
    distance,
    workplaceId,
    slug,
    latitude,
    longitude,
    instagramUrl,
    tiktokUrl,
    phone,
  ];
}
