import '../../domain/entities/user_entity.dart';

/// Modelo de usuario para la capa de datos
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.avatarSeed,
    super.phone,
    super.location,
    super.country,
    super.gender,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      avatarSeed: json['avatarSeed'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      country: json['country'] as String?,
      gender: json['gender'] as String?,
      role: json['role'] as String? ?? 'CLIENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'avatarSeed': avatarSeed,
      'phone': phone,
      'location': location,
      'country': country,
      'gender': gender,
      'role': role,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatar,
      avatarSeed: entity.avatarSeed,
      phone: entity.phone,
      location: entity.location,
      country: entity.country,
      gender: entity.gender,
      role: entity.role,
    );
  }
}

