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

abstract class AdminRepository {
  Stream<List<AdminCityModel>> watchCities();

  Stream<List<AdminRouteModel>> watchRoutes();

  Stream<List<AdminPoiModel>> watchPois();

  Stream<List<AdminMissionModel>> watchMissions();

  Future<String> uploadFile({
    required Uint8List fileBytes,
    required String folder,
    required String fileName,
  });

  Future<void> saveCity(AdminCityModel city);

  Future<void> saveRoute(AdminRouteModel route);

  Future<void> savePoi(AdminPoiModel poi);

  Future<void> saveMission(AdminMissionModel mission);

  Future<void> deleteCity(String id);

  Future<void> deleteRoute(String id);

  Future<void> deletePoi(String id);

  Future<void> deleteMission(String id);
}
