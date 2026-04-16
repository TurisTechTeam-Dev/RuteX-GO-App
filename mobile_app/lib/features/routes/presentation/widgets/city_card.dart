import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/cards/custom_cards.dart';

class CityCard extends StatelessWidget {
  final String title;
  final String image;
  final bool available;
  final String cityId;

  const CityCard({
    super.key,
    required this.title,
    required this.image,
    required this.available,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _CityImage(image: image),
          const SizedBox(height: 8),
          _StrokeCityTitle(text: title),
          const SizedBox(height: 6),
          _RouteCounter(available: available, cityId: cityId),
          const Spacer(),
          _ExploreButton(available: available, cityId: cityId),
        ],
      ),
    );
  }
}

class _CityImage extends StatelessWidget {
  final String image;

  const _CityImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.negroTexto, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: image.startsWith('http')
              ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _CityFallbackIcon(),
                )
              : Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _CityFallbackIcon(),
                ),
        ),
      ),
    );
  }
}

class _CityFallbackIcon extends StatelessWidget {
  const _CityFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.location_city,
      color: AppColors.verdePrincipal,
      size: 48,
    );
  }
}

class _RouteCounter extends StatelessWidget {
  final bool available;
  final String cityId;

  const _RouteCounter({required this.available, required this.cityId});

  @override
  Widget build(BuildContext context) {
    if (!available) {
      return Text(
        "PrÃ³ximamente",
        style: Theme.of(context).textTheme.labelMedium,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("rutas")
          .where("id_ciudad", isEqualTo: cityId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "...",
            style: Theme.of(context).textTheme.labelMedium,
          );
        }

        final routesCount = snapshot.data!.docs.length;

        return Text(
          "$routesCount rutas disponibles",
          style: Theme.of(context).textTheme.labelMedium,
        );
      },
    );
  }
}

class _ExploreButton extends StatelessWidget {
  final bool available;
  final String cityId;

  const _ExploreButton({required this.available, required this.cityId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              available ? AppColors.verdePrincipal : AppColors.grisSombra,
          foregroundColor: AppColors.blancoPuro,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        onPressed: available
            ? () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.routeSelection,
                  arguments: cityId,
                );
              }
            : null,
        child: const Text("Explorar"),
      ),
    );
  }
}

class _StrokeCityTitle extends StatelessWidget {
  final String text;

  const _StrokeCityTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8
              ..color = AppColors.verdePrincipal,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.negroTexto,
          ),
        ),
      ],
    );
  }
}
