import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../domain/entities/city.dart';

class CityModel extends City {
  const CityModel({
    required super.id,
    required super.title,
    required super.image,
    required super.available,
  });

  factory CityModel.fromSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fallbackImage = "assets/images_selection/${doc.id}.jpg";

    return CityModel(
      id: TextNormalizer.toAsciiSlug(doc.id),
      title: data[CityFields.nombre]?.toString() ?? '',
      image: data[CityFields.imagen]?.toString() ?? fallbackImage,
      available: data[CityFields.isActive] == true,
    );
  }
}
