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

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'El formato del email no es válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
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
