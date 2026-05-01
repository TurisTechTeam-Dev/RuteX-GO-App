/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
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
