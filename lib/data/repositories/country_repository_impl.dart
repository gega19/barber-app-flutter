import '../../domain/entities/country_entity.dart';
import '../../domain/repositories/country_repository.dart';
import '../datasources/remote/country_remote_datasource.dart';

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource remoteDataSource;

  CountryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CountryEntity>> getCountries() async {
    return await remoteDataSource.getCountries();
  }

  @override
  Future<String> detectCountry() async {
    return await remoteDataSource.detectCountry();
  }
}
