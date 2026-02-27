import '../repositories/profile_repository.dart';

class ProfileUsesCases {
  final ProfileRepository repository;

  ProfileUsesCases(this.repository);

// --- Caso de Uso 1: Obtener perfil ---
  Future<Map<String, dynamic>> getUserProfile(String uid) {
    return repository.getUserProfile(uid);
  }

// --- Caso de Uso 2: Obtener rutas ---
  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid) {
    return repository.getCompletedRoutes(uid);
  }

// --- Caso de Uso 3: Obtener configuración de rangos ---
  Future<Map<String, dynamic>> getConfigRangos(String configId) {
    return repository.getConfigRangos(configId);
  }

// --- Caso de Uso 4: Logout (Asumiendo que existe en tu repo) ---
  Future<void> logout() {
    return repository.logout();
  }
}