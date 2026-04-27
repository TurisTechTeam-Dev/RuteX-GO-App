import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/framed_storage_image.dart';
import '../../domain/entities/tourist_route.dart';

class RouteCard extends StatelessWidget {
  final TouristRoute route;
  final bool canStart;
  final bool isCheckingAvailability;

  const RouteCard({
    super.key,
    required this.route,
    required this.canStart,
    this.isCheckingAvailability = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildCardContent(context),
        ),
      ),
    );
  }

  List<Widget> _buildCardContent(BuildContext context) {
    final content = <Widget>[
      FramedStorageImage(source: route.image, fallbackIcon: Icons.photo),
      const SizedBox(height: 12),
      _RouteTitle(title: route.title),
    ];

    final description = route.description.trim();
    if (description.isNotEmpty) {
      content.add(const SizedBox(height: 8));
      content.add(
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      );
    }

    content.add(const SizedBox(height: 12));
    content.add(_RouteDetails(route: route));

    final shouldShowBlockedHint = !isCheckingAvailability && !canStart;
    if (shouldShowBlockedHint) {
      content.add(const SizedBox(height: 12));
      content.add(const _RouteBlockedHint());
    }

    content.add(const SizedBox(height: 12));
    content.add(
      _StartRouteButton(
        routeId: route.id,
        canStart: canStart,
        isCheckingAvailability: isCheckingAvailability,
      ),
    );

    return content;
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
  final TouristRoute route;

  const _RouteDetails({required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RouteInfo(Icons.extension, "Dificultad", route.difficulty),
        const SizedBox(height: 6),
        _RouteInfo(Icons.access_time, "Tiempo estimado", route.time),
        const SizedBox(height: 6),
        _RouteInfo(Icons.route, "Puntos totales", route.pointsLabel),
      ],
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RouteInfo(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.verdePrincipal),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteBlockedHint extends StatelessWidget {
  const _RouteBlockedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blancoTarjeta.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grisNeutro.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.grisSombra,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Faltan misiones en uno o varios puntos de interés.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.grisSombra,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartRouteButton extends StatelessWidget {
  final String routeId;
  final bool canStart;
  final bool isCheckingAvailability;

  const _StartRouteButton({
    required this.routeId,
    required this.canStart,
    required this.isCheckingAvailability,
  });

  @override
  Widget build(BuildContext context) {
    final buttonLabel = _buttonLabel();

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canStart
              ? AppColors.verdePrincipal
              : AppColors.grisSombra,
          foregroundColor: AppColors.blancoPuro,
          disabledBackgroundColor: AppColors.grisSombra,
          disabledForegroundColor: AppColors.blancoPuro,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: _buildOnPressed(context),
        child: Text(buttonLabel),
      ),
    );
  }

  VoidCallback? _buildOnPressed(BuildContext context) {
    if (!canStart || isCheckingAvailability) {
      return null;
    }

    return () {
      Navigator.pushNamed(context, AppRoutes.mapNavigation, arguments: routeId);
    };
  }

  String _buttonLabel() {
    if (isCheckingAvailability) {
      return "Comprobando...";
    }

    if (canStart) {
      return "Comenzar ruta";
    }

    return "Ruta no disponible";
  }
}
