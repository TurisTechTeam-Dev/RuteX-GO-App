/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import '../../../../core/constants/firestore_contract.dart';
import 'admin_model_helpers.dart';

class AdminCityModel {
  final String? id;
  final String name;
  final String province;
  final String imageUrl;
  final bool isActive;

  const AdminCityModel({
    this.id,
    required this.name,
    required this.province,
    required this.imageUrl,
    required this.isActive,
  });

  factory AdminCityModel.fromFirestore(Map<String, dynamic> data, String id) {
    final name = (data[CityFields.nombre] ?? '').toString();
    return AdminCityModel(
      id: id,
      name: name,
      province: (data[CityFields.provincia] ?? '').toString(),
      imageUrl:
          adminFirstTextValue(data, const [
            CityFields.imagen,
            'imagen_asset',
            'imagen_url',
            'image',
          ]) ??
          adminCityImagePath(name),
      isActive: data[CityFields.isActive] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      CityFields.nombre: name.trim(),
      CityFields.provincia: province.trim(),
      CityFields.imagen: imageUrl.trim(),
      CityFields.isActive: isActive,
    };
  }
}
