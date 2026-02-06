/// Normaliza un número de teléfono a formato E.164 para envío al backend.
/// Ej: 04241821619, +58 424 182 1619 → +584241821619
String normalizePhoneToE164(String phone) {
  final cleaned = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
  final digits = cleaned.startsWith('+')
      ? cleaned.substring(1).replaceAll(RegExp(r'\D'), '')
      : cleaned.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  final normalized = digits.startsWith('0')
      ? '58${digits.substring(1)}'
      : digits;
  return '+$normalized';
}
