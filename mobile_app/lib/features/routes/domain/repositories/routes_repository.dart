import '../entities/city.dart';
import '../entities/tourist_route.dart';

abstract class RoutesRepository {
  Stream<List<City>> getCities();
  Stream<List<TouristRoute>> getRoutes();
  Stream<List<TouristRoute>> getRoutesByCity(String cityId);
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds);
}
