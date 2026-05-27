import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/country_model.dart';

abstract class CountryRemoteDataSource {
  Future<List<CountryModel>> getCountries();
  Future<String> detectCountry();
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final Dio dio;

  CountryRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/countries');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => CountryModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Error al obtener países',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetCountries error: ${e.message}', error: e);
      throw Exception('Error al obtener países: ${e.message}');
    }
  }

  @override
  Future<String> detectCountry() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/countries/detect');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final country = (data['country'] as String?)?.trim().toUpperCase();
        if (country != null && country.isNotEmpty) {
          return country;
        }
        return 'VE';
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error'] ?? 'Error al detectar país',
      );
    } on DioException catch (e) {
      appLogger.e('DetectCountry error: ${e.message}', error: e);
      return 'VE';
    }
  }
}
