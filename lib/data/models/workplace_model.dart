import '../../domain/entities/workplace_entity.dart';

class WorkplaceModel extends WorkplaceEntity {
  const WorkplaceModel({
    required super.id,
    required super.name,
    super.address,
    super.city,
    super.description,
    super.image,
    super.banner,
    super.rating = 0.0,
    super.reviews = 0,
  });

  factory WorkplaceModel.fromJson(Map<String, dynamic> json) {
    return WorkplaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      banner: json['banner'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviews: json['reviews'] != null ? (json['reviews'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (banner != null) 'banner': banner,
      'rating': rating,
      'reviews': reviews,
    };
  }

  factory WorkplaceModel.fromEntity(WorkplaceEntity entity) {
    return WorkplaceModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      city: entity.city,
      description: entity.description,
      image: entity.image,
      banner: entity.banner,
      rating: entity.rating,
      reviews: entity.reviews,
    );
  }
}
