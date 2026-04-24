import '../../../../core/utils/text_normalizer.dart';

class City {
  final String id;
  final String title;
  final String image;
  final bool available;

  const City({
    required this.id,
    required this.title,
    required this.image,
    required this.available,
  });

  Set<String> get routeKeys {
    return {
      id,
      TextNormalizer.toAsciiSlug(title),
    }.where((key) => key.isNotEmpty).toSet();
  }
}
