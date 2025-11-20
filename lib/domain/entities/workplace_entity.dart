import 'package:equatable/equatable.dart';

class WorkplaceEntity extends Equatable {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? image;
  final String? banner;
  final double rating;
  final int reviews;

  const WorkplaceEntity({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.description,
    this.image,
    this.banner,
    this.rating = 0.0,
    this.reviews = 0,
  });

  @override
  List<Object?> get props => [id, name, address, city, latitude, longitude, description, image, banner, rating, reviews];
}
