import 'package:equatable/equatable.dart';

/// Entidad de usuario del dominio
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? avatarSeed;
  final String? phone;
  final String? location;
  final String? country;
  final String? gender;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.avatarSeed,
    this.phone,
    this.location,
    this.country,
    this.gender,
    this.role = 'CLIENT',
  });

  @override
  List<Object?> get props => [id, name, email, avatar, avatarSeed, phone, location, country, gender, role];
}


