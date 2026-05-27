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
    super.phoneVerified,
    super.location,
    super.country,
    super.suggestedCountry,
    super.gender,
    super.role,
    super.isBarber,
    super.barberId,
    super.mustUpdatePassword,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final phoneVerifiedAt = json['phoneVerifiedAt'];
    final phoneVerified =
        phoneVerifiedAt != null && phoneVerifiedAt.toString().isNotEmpty;
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      avatarSeed: json['avatarSeed'] as String?,
      phone: json['phone'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? phoneVerified,
      location: json['location'] as String?,
      country: json['country'] as String?,
      suggestedCountry: json['suggestedCountry'] as String?,
      gender: json['gender'] as String?,
      role: json['role'] as String? ?? 'CLIENT',
      isBarber: json['isBarber'] as bool? ?? false,
      barberId: json['barberId'] as String?,
      mustUpdatePassword: json['mustUpdatePassword'] as bool? ?? false,
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
      'phoneVerified': phoneVerified,
      'location': location,
      'country': country,
      'suggestedCountry': suggestedCountry,
      'gender': gender,
      'role': role,
      'isBarber': isBarber,
      'barberId': barberId,
      'mustUpdatePassword': mustUpdatePassword,
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
      phoneVerified: entity.phoneVerified,
      location: entity.location,
      country: entity.country,
      suggestedCountry: entity.suggestedCountry,
      gender: entity.gender,
      role: entity.role,
      isBarber: entity.isBarber,
      barberId: entity.barberId,
      mustUpdatePassword: entity.mustUpdatePassword,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? avatarSeed,
    String? phone,
    bool? phoneVerified,
    String? location,
    String? country,
    String? suggestedCountry,
    String? gender,
    String? role,
    bool? isBarber,
    String? barberId,
    bool? mustUpdatePassword,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      location: location ?? this.location,
      country: country ?? this.country,
      suggestedCountry: suggestedCountry ?? this.suggestedCountry,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isBarber: isBarber ?? this.isBarber,
      barberId: barberId ?? this.barberId,
      mustUpdatePassword: mustUpdatePassword ?? this.mustUpdatePassword,
    );
  }
}
