/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:latlong2/latlong.dart';

class NavigationDistanceUtils {
  const NavigationDistanceUtils._();

  static double metersBetween(LatLng from, LatLng to) {
    return const Distance().as(LengthUnit.Meter, from, to);
  }
}
