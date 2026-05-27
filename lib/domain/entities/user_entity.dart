import 'package:equatable/equatable.dart';

/// Entidad de usuario del dominio
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? avatarSeed;
  final String? phone;
  final bool phoneVerified;
  final String? location;
  final String? country;
  final String? suggestedCountry;
  final String? gender;
  final String role;
  final bool isBarber;
  final String? barberId;
  final bool mustUpdatePassword;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.avatarSeed,
    this.phone,
    this.phoneVerified = false,
    this.location,
    this.country,
    this.suggestedCountry,
    this.gender,
    this.role = 'CLIENT',
    this.isBarber = false,
    this.barberId,
    this.mustUpdatePassword = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    avatar,
    avatarSeed,
    phone,
    phoneVerified,
    location,
    country,
    suggestedCountry,
    gender,
    role,
    isBarber,
    barberId,
    mustUpdatePassword,
  ];
}
