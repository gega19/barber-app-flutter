/// Formato de precio usando el símbolo del barbero (API: priceCurrencySymbol).
class PriceDisplay {
  PriceDisplay._();

  static String format(
    double amount, {
    String? currencySymbol,
    int fractionDigits = 2,
  }) {
    final sym = currencySymbol ?? r'$';
    return '$sym${amount.toStringAsFixed(fractionDigits)}';
  }
}
