import '../entities/country_entity.dart';

abstract class CountryRepository {
  Future<List<CountryEntity>> getCountries();
  Future<String> detectCountry();
}
