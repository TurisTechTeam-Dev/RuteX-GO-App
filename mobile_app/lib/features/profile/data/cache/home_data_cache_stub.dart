/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../../domain/entities/home_data.dart';

class HomeDataCache {
  const HomeDataCache();

  Future<HomeData?> read(String uid) async => null;

  Future<void> save(String uid, HomeData data) async {}
}
