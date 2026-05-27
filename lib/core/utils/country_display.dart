/// Emoji flag for LATAM-ish catalog UX (fallback blank if unknown).
String countryEmojiForCode(String code) {
  switch (code.toUpperCase()) {
    case 'VE':
      return '🇻🇪';
    case 'CO':
      return '🇨🇴';
    case 'MX':
      return '🇲🇽';
    case 'AR':
      return '🇦🇷';
    case 'PE':
      return '🇵🇪';
    case 'CL':
      return '🇨🇱';
    case 'EC':
      return '🇪🇨';
    case 'BO':
      return '🇧🇴';
    case 'UY':
      return '🇺🇾';
    case 'PY':
      return '🇵🇾';
    case 'CR':
      return '🇨🇷';
    case 'PA':
      return '🇵🇦';
    case 'HN':
      return '🇭🇳';
    case 'GT':
      return '🇬🇹';
    case 'DO':
      return '🇩🇴';
    case 'SV':
      return '🇸🇻';
    case 'NI':
      return '🇳🇮';
    case 'CU':
      return '🇨🇺';
    case 'PR':
      return '🇵🇷';
    case 'BR':
      return '🇧🇷';
    default:
      return '🌍';
  }
}
