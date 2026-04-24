import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/storage_aware_image.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final String displayName;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _ProfileAvatar(avatarUrl: user.avatarUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.negroTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(color: AppColors.grisNeutro),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.grisNeutro),
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

  const _ProfileAvatar({required this.avatarUrl});

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
