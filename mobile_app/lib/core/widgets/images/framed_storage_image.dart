import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'storage_aware_image.dart';

class FramedStorageImage extends StatelessWidget {
  final String source;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const FramedStorageImage({
    super.key,
    required this.source,
    required this.fallbackIcon,
    this.fallbackIconSize = 42,
  });

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
          child: StorageAwareImage(
            source: source,
            fit: BoxFit.cover,
            placeholder: const _ImageLoadingState(),
            fallback: _FallbackImage(
              icon: fallbackIcon,
              iconSize: fallbackIconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageLoadingState extends StatelessWidget {
  const _ImageLoadingState();

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

class _FallbackImage extends StatelessWidget {
  final IconData icon;
  final double iconSize;

  const _FallbackImage({required this.icon, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blancoTarjeta,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.verdePrincipal, size: iconSize),
    );
  }
}
