/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/routes/domain/entities/city.dart';
import 'package:mobile_app/features/routes/domain/entities/tourist_route.dart';
import 'package:mobile_app/features/routes/domain/repositories/routes_repository.dart';
import 'package:mobile_app/features/routes/domain/usecases/routes_use_cases.dart';

void main() {
  group('RoutesUseCases.executeGetRouteAvailability', () {
    test('enables route when every point has at least one mission', () async {
      final useCases = RoutesUseCases(
        _FakeRoutesRepository({'poi-1', 'poi-2'}),
      );

      final availability = await useCases.executeGetRouteAvailability([
        _route('route-1', ['poi-1', 'poi-2']),
      ]);

      expect(availability['route-1'], isTrue);
    });

    test('disables route when any point has no mission', () async {
      final useCases = RoutesUseCases(_FakeRoutesRepository({'poi-1'}));

      final availability = await useCases.executeGetRouteAvailability([
        _route('route-1', ['poi-1', 'poi-2']),
      ]);

      expect(availability['route-1'], isFalse);
    });

    test('disables route without points of interest', () async {
      final useCases = RoutesUseCases(_FakeRoutesRepository({'poi-1'}));

      final availability = await useCases.executeGetRouteAvailability([
        _route('route-1', const []),
      ]);

      expect(availability['route-1'], isFalse);
    });
  });
}

TouristRoute _route(String id, List<String> pointIds) {
  return TouristRoute(
    id: id,
    cityId: 'caceres',
    title: 'Caceres medieval',
    description: '',
    difficulty: 'Media',
    time: '60 min',
    pointIds: pointIds,
    totalPois: pointIds.length,
    totalPoints: 100,
    image: '',
  );
}

class _FakeRoutesRepository implements RoutesRepository {
  final Set<String> pointIdsWithMission;

  const _FakeRoutesRepository(this.pointIdsWithMission);

  @override
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds) async {
    return pointIdsWithMission;
  }

  @override
  Future<Map<String, String>> getPointNamesByIds(List<String> pointIds) async {
    return const <String, String>{};
  }

  @override
  Stream<List<City>> getCities() {
    throw UnimplementedError();
  }

  @override
  Stream<List<TouristRoute>> getRoutes() {
    throw UnimplementedError();
  }

  @override
  Stream<List<TouristRoute>> getRoutesByCity(String cityId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TouristRoute>> getRoutesByCityKeys(Set<String> cityKeys) {
    throw UnimplementedError();
  }
}
