/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../../../../core/constants/firestore_contract.dart';
import 'admin_model_helpers.dart';

class AdminRouteModel {
  final String? id;
  final String name;
  final String difficulty;
  final String duration;
  final String cityId;
  final List<String> pointIds;
  final String image;
  final bool isActive;
  final int totalPoints;

  const AdminRouteModel({
    this.id,
    required this.name,
    required this.difficulty,
    required this.duration,
    required this.cityId,
    required this.pointIds,
    required this.image,
    required this.isActive,
    required this.totalPoints,
  });

  factory AdminRouteModel.fromFirestore(Map<String, dynamic> data, String id) {
    final pointsRaw = data[RouteFields.idPuntosInteres];
    final name = (data[RouteFields.nombre] ?? '').toString();

    return AdminRouteModel(
      id: id,
      name: name,
      difficulty: (data[RouteFields.dificultad] ?? '').toString(),
      duration: (data[RouteFields.duracion] ?? '').toString(),
      cityId: adminIdFromFirestoreValue(
        data[RouteFields.idCiudad] ??
            data['idCiudad'] ??
            data['ciudad_id'] ??
            data['ciudadId'] ??
            data['id_ciudades'] ??
            data['ciudad'] ??
            data['cityId'] ??
            data['city_id'] ??
            data['city'],
      ),
      pointIds: pointsRaw is List
          ? pointsRaw.map(adminIdFromFirestoreValue).where(adminIsNotEmpty).toList()
          : <String>[],
      image:
      adminFirstTextValue(data, const [
        RouteFields.imagen,
        'image',
        'imagen_url',
      ]) ??
          adminRouteImagePath(name),
      isActive:
      data[RouteFields.isActive] == true ||
          data[RouteFields.isActive] == 'true',
      totalPoints:
      int.tryParse(data[RouteFields.puntosTotales]?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      RouteFields.nombre: name.trim(),
      RouteFields.dificultad: difficulty.trim(),
      RouteFields.duracion: duration.trim(),
      RouteFields.idCiudad: cityId,
      RouteFields.idPuntosInteres: pointIds,
      RouteFields.imagen: image.trim(),
      RouteFields.isActive: isActive,
      RouteFields.puntosTotales: totalPoints,
    };
  }
}