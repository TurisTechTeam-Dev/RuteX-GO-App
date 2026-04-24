import 'package:latlong2/latlong.dart';

class NavigationDistanceUtils {
  const NavigationDistanceUtils._();

  static double metersBetween(LatLng from, LatLng to) {
    return const Distance().as(LengthUnit.Meter, from, to);
  }
}
