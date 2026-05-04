/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../entities/city.dart';
import '../entities/tourist_route.dart';

abstract class RoutesRepository {
  Stream<List<City>> getCities();
  Stream<List<TouristRoute>> getRoutes();
  Stream<List<TouristRoute>> getRoutesByCity(String cityId);
  Stream<List<TouristRoute>> getRoutesByCityKeys(Set<String> cityKeys);
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds);
  Future<Map<String, String>> getPointNamesByIds(List<String> pointIds);
}
