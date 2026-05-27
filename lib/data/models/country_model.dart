import '../../domain/entities/country_entity.dart';

class CountryModel extends CountryEntity {
  const CountryModel({
    required super.code,
    required super.name,
    required super.timezone,
    required super.phonePrefix,
    required super.currency,
    required super.currencySymbol,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
      timezone: json['timezone'] as String,
      phonePrefix: json['phonePrefix'] as String,
      currency: json['currency'] as String,
      currencySymbol: json['currencySymbol'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'timezone': timezone,
      'phonePrefix': phonePrefix,
      'currency': currency,
      'currencySymbol': currencySymbol,
    };
  }
}
