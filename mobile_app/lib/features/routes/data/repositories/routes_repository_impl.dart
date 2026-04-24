import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/tourist_route.dart';
import '../../domain/repositories/routes_repository.dart';
import '../datasources/routes_remote_datasource.dart';
import '../models/city_model.dart';
import '../models/route_model.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  static const int _firestoreWhereInLimit = 10;

  final RoutesRemoteDatasource remoteDatasource;

  RoutesRepositoryImpl({RoutesRemoteDatasource? remoteDatasource})
    : remoteDatasource =
          remoteDatasource ??
          RoutesRemoteDatasource(FirebaseFirestore.instance);

  @override
  Stream<List<City>> getCities() {
    return remoteDatasource.watchCities().map(
      (snapshot) => snapshot.docs.map(CityModel.fromSnapshot).toList(),
    );
  }

  @override
  Stream<List<TouristRoute>> getRoutes() {
    return remoteDatasource.watchRoutes().map(
      (snapshot) => snapshot.docs.map(RouteModel.fromSnapshot).toList(),
    );
  }

  @override
  Stream<List<TouristRoute>> getRoutesByCity(String cityId) {
    return remoteDatasource
        .watchRoutesByCity(cityId)
        .map((snapshot) => snapshot.docs.map(RouteModel.fromSnapshot).toList());
  }

  @override
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds) async {
    if (pointIds.isEmpty) return <String>{};

    final pointIdsWithMission = <String>{};

    for (var i = 0; i < pointIds.length; i += _firestoreWhereInLimit) {
      final chunk = pointIds.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await remoteDatasource.getMissionsByPointIds(chunk);

      for (final doc in snapshot.docs) {
        final pointId = doc.data()[MissionFields.puntosInteresId]?.toString();
        if (pointId != null && pointId.isNotEmpty) {
          pointIdsWithMission.add(pointId);
        }
      }
    }

    return pointIdsWithMission;
  }
}
