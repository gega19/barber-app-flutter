import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? name,
    String? phone,
    String? location,
    String? country,
    String? gender,
    String? avatar,
    String? avatarSeed,
  }) async {
    return await repository.updateProfile(
      name: name,
      phone: phone,
      location: location,
      country: country,
      gender: gender,
      avatar: avatar,
      avatarSeed: avatarSeed,
    );
  }
}
