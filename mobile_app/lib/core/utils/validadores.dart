class Validadores {
  static String? validarCampoVacio(String? value, String nombreCampo) {
    if (value == null || value.isEmpty) {
      return 'El campo $nombreCampo es obligatorio';
    }
    return null;
  }

  static String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }

    // Expresión regular para validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'El formato del email no es válido';
    }
    return null;
  }

  static String? validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validarCoincidencia(String? value, String passwordOriginal) {
    if (value != passwordOriginal) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return "El nombre es obligatorio";
    }
    if (value.length > 20) {
      return "El nombre no puede tener más de 20 caracteres";
    }
    return null;
  }
}
