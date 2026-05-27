import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final String code;
  final String name;
  final String timezone;
  final String phonePrefix;
  final String currency;
  final String currencySymbol;

  const CountryEntity({
    required this.code,
    required this.name,
    required this.timezone,
    required this.phonePrefix,
    required this.currency,
    required this.currencySymbol,
  });

  @override
  List<Object?> get props => [
        code,
        name,
        timezone,
        phonePrefix,
        currency,
        currencySymbol,
      ];
}
