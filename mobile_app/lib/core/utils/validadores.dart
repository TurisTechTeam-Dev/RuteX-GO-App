class Validadores {
  static bool esEmailValido(String email) {
    final RegExp emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  static bool esPasswordValido(String password) {
    return password.length >= 6;
  }
}
