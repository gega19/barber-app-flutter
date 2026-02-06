import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/competition_repository.dart';

class GetHelpRulesUseCase {
  final CompetitionRepository repository;

  GetHelpRulesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() => repository.getHelpRules();
}
