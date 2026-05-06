/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
class Validators {
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'El formato del email no es válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    // Longitud mínima de 8 caracteres (según tu captura)
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Exigir caracteres en mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }

    // Exigir caracteres en minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }

    // Exigir caracteres numéricos
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }

    // Exigir caracteres especiales
    // Esta regex cubre los caracteres especiales más comunes
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+-]'))) {
      return 'Debe contener al menos un carácter especial';
    }

    return null;
  }

  static String? validatePasswordMatch(String? value, String originalPassword) {
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "El nombre es obligatorio";
    }
    if (value.length > 20) {
      return "El nombre no puede tener más de 20 caracteres";
    }
    return null;
  }
}
