import '../../entities/country_entity.dart';
import '../../repositories/country_repository.dart';

class GetCountriesUseCase {
  final CountryRepository repository;

  GetCountriesUseCase(this.repository);

  Future<List<CountryEntity>> call() async {
    return await repository.getCountries();
  }
}
