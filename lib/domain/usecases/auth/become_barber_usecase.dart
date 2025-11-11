import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class BecomeBarberUseCase {
  final AuthRepository repository;

  BecomeBarberUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? specialtyId,
    required String specialty,
    required int experienceYears,
    required String location,
    double? latitude,
    double? longitude,
    String? image,
    String? workplaceId,
    String? serviceType,
  }) async {
    return await repository.becomeBarber(
      specialtyId: specialtyId,
      specialty: specialty,
      experienceYears: experienceYears,
      location: location,
      latitude: latitude,
      longitude: longitude,
      image: image,
      workplaceId: workplaceId,
      serviceType: serviceType,
    );
  }
}
