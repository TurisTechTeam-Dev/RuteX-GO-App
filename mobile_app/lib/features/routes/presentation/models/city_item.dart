import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class CityItem {
  final String id;
  final String title;
  final String image;
  final bool available;

  const CityItem({
    required this.id,
    required this.title,
    required this.image,
    required this.available,
  });

  factory CityItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fallbackImage = "assets/images_selection/${doc.id}.jpg";

    return CityItem(
      id: doc.id,
      title: data[CityFields.nombre]?.toString() ?? '',
      image: data[CityFields.imagen]?.toString() ?? fallbackImage,
      available: data[CityFields.isActive] == true,
    );
  }
}
