import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/country/get_countries_usecase.dart';
import 'country_state.dart';

class CountryCubit extends Cubit<CountryState> {
  final GetCountriesUseCase getCountriesUseCase;

  CountryCubit({required this.getCountriesUseCase}) : super(CountryInitial());

  Future<void> fetchCountries() async {
    try {
      emit(CountryLoading());
      final countries = await getCountriesUseCase();
      emit(CountryLoaded(countries));
    } catch (e) {
      emit(CountryError(e.toString()));
    }
  }
}
