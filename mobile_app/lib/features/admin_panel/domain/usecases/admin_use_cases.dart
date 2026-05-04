/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'dart:typed_data';

import '../../data/models/admin_models.dart';
import '../repositories/admin_repository.dart';

class AdminUseCases {
  final AdminRepository repository;

  const AdminUseCases(this.repository);

  Stream<List<AdminCityModel>> watchCities() {
    return repository.watchCities();
  }

  Stream<List<AdminRouteModel>> watchRoutes() {
    return repository.watchRoutes();
  }

  Stream<List<AdminPoiModel>> watchPois() {
    return repository.watchPois();
  }

  Stream<List<AdminMissionModel>> watchMissions() {
    return repository.watchMissions();
  }

  Future<String> uploadFile({
    required Uint8List fileBytes,
    required String folder,
    required String fileName,
  }) {
    return repository.uploadFile(
      fileBytes: fileBytes,
      folder: folder,
      fileName: fileName,
    );
  }

  Future<void> saveCity(AdminCityModel city) {
    return repository.saveCity(city);
  }

  Future<void> saveRoute(AdminRouteModel route) {
    return repository.saveRoute(route);
  }

  Future<void> savePoi(AdminPoiModel poi) {
    return repository.savePoi(poi);
  }

  Future<void> saveMission(AdminMissionModel mission) {
    return repository.saveMission(mission);
  }

  Future<void> deleteCity(String id) {
    return repository.deleteCity(id);
  }

  Future<void> deleteRoute(String id) {
    return repository.deleteRoute(id);
  }

  Future<void> deletePoi(String id) {
    return repository.deletePoi(id);
  }

  Future<void> deleteMission(String id) {
    return repository.deleteMission(id);
  }
}
