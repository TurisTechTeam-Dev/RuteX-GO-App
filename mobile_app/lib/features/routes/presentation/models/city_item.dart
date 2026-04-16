import 'package:cloud_firestore/cloud_firestore.dart';

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
      title: data['nombre']?.toString() ?? '',
      image: data['imagen']?.toString() ?? fallbackImage,
      available: data['isActive'] == true,
    );
  }
}
