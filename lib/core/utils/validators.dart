/// Utilities for form validation
class Validators {
  Validators._();

  /// Regex to validate email
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Regex to validate name (only letters, spaces, accents and some special characters)
  static final RegExp _nameRegex = RegExp(
    r"^[a-zA-ZÀ-ÿ\s\-'\.]{2,50}$",
  );

  /// Validates email using robust regex
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Validates name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (trimmedValue.length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    if (!_nameRegex.hasMatch(trimmedValue)) {
      return 'El nombre solo puede contener letras, espacios y algunos caracteres especiales';
    }
    return null;
  }

  /// Validates password
  static String? validatePassword(String? value, {bool isRegister = false}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (isRegister && value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }
}

