import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../models/route_item.dart';

class RouteCard extends StatelessWidget {
  final RouteItem route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RouteImage(image: route.image),
            const SizedBox(height: 10),
            _RouteTitle(title: route.title),
            const SizedBox(height: 6),
            Text(
              route.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 10),
            _RouteDetails(route: route),
            const SizedBox(height: 12),
            _StartRouteButton(routeId: route.id),
          ],
        ),
      ),
    );
  }
}

class _RouteImage extends StatelessWidget {
  final String image;

  const _RouteImage({required this.image});

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
              ? Image.network(image, fit: BoxFit.cover)
              : Image.asset(image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _RouteTitle extends StatelessWidget {
  final String title;

  const _RouteTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_balance,
          color: AppColors.verdePrincipal,
          size: 20,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteDetails extends StatelessWidget {
  final RouteItem route;

  const _RouteDetails({required this.route});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        _RouteInfo(Icons.extension, "Dificultad: ${route.difficulty}"),
        _RouteInfo(Icons.access_time, "Tiempo: ${route.time}"),
        _RouteInfo(Icons.route, "Puntos: ${route.pointsLabel}"),
      ],
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RouteInfo(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.verdePrincipal),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _StartRouteButton extends StatelessWidget {
  final String routeId;

  const _StartRouteButton({required this.routeId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrincipal,
          foregroundColor: AppColors.blancoPuro,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.mapNavigation,
            arguments: routeId,
          );
        },
        child: const Text("Comenzar ruta"),
      ),
    );
  }
}
