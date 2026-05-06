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
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/storage_aware_image.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final String displayName;
  final bool isUploadingAvatar;
  final VoidCallback onChangeAvatar;
  final VoidCallback onEditUsername;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.displayName,
    required this.isUploadingAvatar,
    required this.onChangeAvatar,
    required this.onEditUsername,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _ProfileAvatar(
            avatarUrl: user.avatarUrl,
            isUploading: isUploadingAvatar,
            onChangeAvatar: onChangeAvatar,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar usuario',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit, size: 20),
                      color: AppColors.verdePrincipal,
                      onPressed: onEditUsername,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final bool isUploading;
  final VoidCallback onChangeAvatar;

  const _ProfileAvatar({
    required this.avatarUrl,
    required this.isUploading,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = _AvatarImage(avatarUrl: avatarUrl);

    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: avatar),
          Positioned(
            right: -2,
            bottom: -2,
            child: SizedBox(
              width: 30,
              height: 30,
              child: FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Cambiar foto',
                backgroundColor: AppColors.verdePrincipal,
                foregroundColor: AppColors.blancoPuro,
                onPressed: isUploading ? null : onChangeAvatar,
                child: isUploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.blancoPuro,
                        ),
                      )
                    : const Icon(Icons.photo_camera, size: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String avatarUrl;

  const _AvatarImage({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 34,
        backgroundColor: AppColors.verdePrincipal,
        child: Icon(Icons.person, color: AppColors.blancoPuro, size: 34),
      );
    }

    return ClipOval(
      child: StorageAwareImage(
        source: avatarUrl,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        fallback: const CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.verdePrincipal,
          child: Icon(Icons.person, color: AppColors.blancoPuro, size: 34),
        ),
      ),
    );
  }
}
