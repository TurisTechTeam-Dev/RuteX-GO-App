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
    final keys = <String>{};

    if (id.isNotEmpty) {
      keys.add(id);
    }

    final normalizedTitle = TextNormalizer.toAsciiSlug(title);
    if (normalizedTitle.isNotEmpty) {
      keys.add(normalizedTitle);
    }

    return keys;
  }
}
