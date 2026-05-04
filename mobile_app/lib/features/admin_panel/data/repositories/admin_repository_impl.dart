import 'dart:typed_data';

import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/admin_models.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  const AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<AdminCityModel>> watchCities() {
    return remoteDataSource.watchCities();
  }

  @override
  Stream<List<AdminRouteModel>> watchRoutes() {
    return remoteDataSource.watchRoutes();
  }

  @override
  Stream<List<AdminPoiModel>> watchPois() {
    return remoteDataSource.watchPois();
  }

  @override
  Stream<List<AdminMissionModel>> watchMissions() {
    return remoteDataSource.watchMissions();
  }

  @override
  Future<String> uploadFile({
    required Uint8List fileBytes,
    required String folder,
    required String fileName,
  }) {
    return remoteDataSource.uploadFile(fileBytes, folder, fileName);
  }

  @override
  Future<void> saveCity(AdminCityModel city) {
    return remoteDataSource.saveCity(city);
  }

  @override
  Future<void> saveRoute(AdminRouteModel route) {
    return remoteDataSource.saveRoute(route);
  }

  @override
  Future<void> savePoi(AdminPoiModel poi) {
    return remoteDataSource.savePoi(poi);
  }

  @override
  Future<void> saveMission(AdminMissionModel mission) {
    return remoteDataSource.saveMission(mission);
  }

  @override
  Future<void> deleteCity(String id) {
    return remoteDataSource.deleteCity(id);
  }

  @override
  Future<void> deleteRoute(String id) {
    return remoteDataSource.deleteRoute(id);
  }

  @override
  Future<void> deletePoi(String id) {
    return remoteDataSource.deletePoi(id);
  }

  @override
  Future<void> deleteMission(String id) {
    return remoteDataSource.deleteMission(id);
  }
}
