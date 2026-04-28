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

  final RoutesRemoteDataSource remoteDataSource;

  RoutesRepositoryImpl({RoutesRemoteDataSource? remoteDataSource})
    : remoteDataSource =
          remoteDataSource ??
          RoutesRemoteDataSource(FirebaseFirestore.instance);

  @override
  Stream<List<City>> getCities() async* {
    await for (final snapshot in remoteDataSource.watchCities()) {
      yield _citiesFromSnapshot(snapshot);
    }
  }

  @override
  Stream<List<TouristRoute>> getRoutes() async* {
    await for (final snapshot in remoteDataSource.watchRoutes()) {
      yield _routesFromSnapshot(snapshot);
    }
  }

  @override
  Stream<List<TouristRoute>> getRoutesByCity(String cityId) {
    return getRoutesByCityKeys({cityId});
  }

  @override
  Stream<List<TouristRoute>> getRoutesByCityKeys(Set<String> cityKeys) async* {
    await for (final routes in getRoutes()) {
      yield _filterRoutesByCityKeys(routes, cityKeys);
    }
  }

  @override
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds) async {
    if (pointIds.isEmpty) return <String>{};

    final pointIdsWithMission = <String>{};

    for (var i = 0; i < pointIds.length; i += _firestoreWhereInLimit) {
      final chunk = pointIds.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await remoteDataSource.getMissionsByPointIds(chunk);

      for (final doc in snapshot.docs) {
        final pointId = _pointIdFromMissionData(doc.data());
        if (pointId != null && pointId.isNotEmpty) {
          pointIdsWithMission.add(pointId);
        }
      }

      final singularSnapshot = await remoteDataSource
          .getMissionsBySingularPointIds(chunk);

      for (final doc in singularSnapshot.docs) {
        final pointId = _pointIdFromMissionData(doc.data());
        if (pointId != null && pointId.isNotEmpty) {
          pointIdsWithMission.add(pointId);
        }
      }

      final refsSnapshot = await remoteDataSource.getMissionsByPointRefs(chunk);

      for (final doc in refsSnapshot.docs) {
        final pointId = _pointIdFromMissionData(doc.data());
        if (pointId != null && pointId.isNotEmpty) {
          pointIdsWithMission.add(pointId);
        }
      }

      final singularRefsSnapshot = await remoteDataSource
          .getMissionsBySingularPointRefs(chunk);

      for (final doc in singularRefsSnapshot.docs) {
        final pointId = _pointIdFromMissionData(doc.data());
        if (pointId != null && pointId.isNotEmpty) {
          pointIdsWithMission.add(pointId);
        }
      }
    }

    return pointIdsWithMission;
  }

  @override
  Future<Map<String, String>> getPointNamesByIds(List<String> pointIds) async {
    if (pointIds.isEmpty) return const <String, String>{};

    final pointNamesById = <String, String>{};

    for (var i = 0; i < pointIds.length; i += _firestoreWhereInLimit) {
      final chunk = pointIds.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await remoteDataSource.getPointsByIds(chunk);

      for (final doc in snapshot.docs) {
        final name = doc.data()[PointInterestFields.nombre]?.toString().trim();

        if (name != null && name.isNotEmpty) {
          pointNamesById[doc.id] = name;
        }
      }
    }

    return pointNamesById;
  }

  List<City> _citiesFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final cities = <City>[];

    for (final doc in snapshot.docs) {
      cities.add(CityModel.fromSnapshot(doc));
    }

    return cities;
  }

  List<TouristRoute> _routesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final routes = <TouristRoute>[];

    for (final doc in snapshot.docs) {
      routes.add(RouteModel.fromSnapshot(doc));
    }

    return routes;
  }

  List<TouristRoute> _filterRoutesByCityKeys(
    List<TouristRoute> routes,
    Set<String> cityKeys,
  ) {
    final filteredRoutes = <TouristRoute>[];

    for (final route in routes) {
      if (cityKeys.contains(route.cityId)) {
        filteredRoutes.add(route);
      }
    }

    return filteredRoutes;
  }

  String? _pointIdFromMissionData(Map<String, dynamic> data) {
    return _pointIdFromMissionValue(data[MissionFields.puntosInteresId]) ??
        _pointIdFromMissionValue(data[MissionFields.puntoInteresId]);
  }

  String? _pointIdFromMissionValue(dynamic rawValue) {
    if (rawValue == null) return null;

    if (rawValue is DocumentReference) {
      return rawValue.id.trim();
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) return null;

    final segments = value.split('/');
    final lastSegment = segments.last.trim();
    return lastSegment.isEmpty ? value : lastSegment;
  }
}
