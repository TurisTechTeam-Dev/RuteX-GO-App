import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/storage_aware_image.dart';
import '../models/city_item.dart';

class CityCard extends StatelessWidget {
  final CityItem city;
  final Stream<QuerySnapshot> routesStream;

  const CityCard({super.key, required this.city, required this.routesStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: routesStream,
      builder: (context, snapshot) {
        final routesCount = snapshot.data?.docs.length ?? 0;
        final hasRoutes = routesCount > 0;

        return CustomCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _CityImage(image: city.image),
              const SizedBox(height: 8),
              _StrokeCityTitle(text: city.title),
              const SizedBox(height: 6),
              _RouteCounter(
                hasRoutes: hasRoutes,
                isLoading: snapshot.connectionState == ConnectionState.waiting,
                routesCount: routesCount,
              ),
              const Spacer(),
              _ExploreButton(hasRoutes: hasRoutes, cityId: city.id),
            ],
          ),
        );
      },
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
          child: _CityImageContent(image: image),
        ),
      ),
    );
  }
}

class _CityImageContent extends StatelessWidget {
  final String image;

  const _CityImageContent({required this.image});

  @override
  Widget build(BuildContext context) {
    return StorageAwareImage(
      source: image,
      fit: BoxFit.cover,
      placeholder: const _CityLoadingState(),
      fallback: const _CityFallbackIcon(),
    );
  }
}

class _CityLoadingState extends StatelessWidget {
  const _CityLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blancoTarjeta,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
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
  final bool hasRoutes;
  final bool isLoading;
  final int routesCount;

  const _RouteCounter({
    required this.hasRoutes,
    required this.isLoading,
    required this.routesCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Text("...", style: Theme.of(context).textTheme.labelMedium);
    }

    if (!hasRoutes) {
      return Text(
        "Proximamente",
        style: Theme.of(context).textTheme.labelMedium,
      );
    }

    return Text(
      "$routesCount rutas disponibles",
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class _ExploreButton extends StatelessWidget {
  final bool hasRoutes;
  final String cityId;

  const _ExploreButton({required this.hasRoutes, required this.cityId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasRoutes
              ? AppColors.verdePrincipal
              : AppColors.grisSombra,
          foregroundColor: AppColors.blancoPuro,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        onPressed: hasRoutes
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
