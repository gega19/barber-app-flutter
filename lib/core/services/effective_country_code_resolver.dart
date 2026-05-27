import '../../domain/repositories/country_repository.dart';
import '../../presentation/cubit/auth/auth_cubit.dart';

/// Solo resuelve el país del usuario autenticado, o 'VE' si no hay usuario.
class EffectiveCountryCodeResolver {
  EffectiveCountryCodeResolver(this._countryRepository);

  final CountryRepository _countryRepository;

  static const defaultCountry = 'VE';
  String? _anonymousCountryCache;

  String resolveForAuthState(AuthState authState) {
    if (authState is AuthAuthenticated) {
      final c = authState.user.country?.trim();
      if (c != null && c.isNotEmpty) {
        return c.toUpperCase();
      }
    }
    if (_anonymousCountryCache != null && _anonymousCountryCache!.isNotEmpty) {
      return _anonymousCountryCache!;
    }
    return defaultCountry;
  }

  Future<String> resolveForAuthStateAsync(AuthState authState) async {
    if (authState is AuthAuthenticated) {
      final c = authState.user.country?.trim();
      if (c != null && c.isNotEmpty) {
        return c.toUpperCase();
      }
    }

    if (_anonymousCountryCache != null && _anonymousCountryCache!.isNotEmpty) {
      return _anonymousCountryCache!;
    }

    final detected = (await _countryRepository.detectCountry()).trim().toUpperCase();
    _anonymousCountryCache = detected.isNotEmpty ? detected : defaultCountry;
    return _anonymousCountryCache!;
  }

  void clearAnonymousCountryCache() {
    _anonymousCountryCache = null;
  }
}
