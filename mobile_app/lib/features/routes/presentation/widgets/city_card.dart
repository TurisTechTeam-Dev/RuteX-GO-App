/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/framed_storage_image.dart';
import '../../domain/entities/city.dart';
import '../models/route_selection_args.dart';

class CityCard extends StatelessWidget {
  final City city;
  final int routesCount;
  final bool isLoadingRoutes;

  const CityCard({
    super.key,
    required this.city,
    required this.routesCount,
    required this.isLoadingRoutes,
  });

  @override
  Widget build(BuildContext context) {
    final hasRoutes = routesCount > 0;

    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          FramedStorageImage(
            source: city.image,
            fallbackIcon: Icons.location_city,
            fallbackIconSize: 48,
          ),
          const SizedBox(height: 8),
          _StrokeCityTitle(text: city.title),
          const SizedBox(height: 6),
          _RouteCounter(
            hasRoutes: hasRoutes,
            isLoading: isLoadingRoutes,
            routesCount: routesCount,
          ),
          const Spacer(),
          _ExploreButton(hasRoutes: hasRoutes, city: city),
        ],
      ),
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
        "Próximamente",
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
  final City city;

  const _ExploreButton({required this.hasRoutes, required this.city});

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
                  arguments: RouteSelectionArgs(cityKeys: city.routeKeys),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
