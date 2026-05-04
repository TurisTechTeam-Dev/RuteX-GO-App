import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/logout_button.dart';

enum AdminNavTab { routes, cities, missions, pointsOfInterest }

class AdminNavbar extends StatelessWidget {
  final AdminNavTab? activeTab;
  final ValueChanged<AdminNavTab> onTabChanged;
  final VoidCallback? onMenuPressed;

  const AdminNavbar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;
        return Material(
          elevation: 2,
          color: AppColors.blancoPuro,
          child: SizedBox(
            height: isCompact ? 116 : 70,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 20),
              child: isCompact ? _buildCompactNavbar() : _buildDesktopNavbar(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopNavbar() {
    return Row(
      children: [
        Image.asset('assets/Logo_Negro_Rutexgo.png', height: 60),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 8,
              children: [
                _buildNavButton(AdminNavTab.cities, 'Ciudades'),
                _buildNavButton(
                  AdminNavTab.pointsOfInterest,
                  'Puntos de interés',
                ),
                _buildNavButton(AdminNavTab.missions, 'Misiones'),
                _buildNavButton(AdminNavTab.routes, 'Rutas'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 180, child: LogoutButton()),
      ],
    );
  }

  Widget _buildCompactNavbar() {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Row(
            children: [
              if (onMenuPressed != null)
                IconButton(
                  tooltip: 'Abrir panel',
                  icon: const Icon(Icons.menu),
                  onPressed: onMenuPressed,
                ),
              Image.asset('assets/Logo_Negro_Rutexgo.png', height: 48),
              const Spacer(),
              const LogoutButton(compact: true),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildNavButton(AdminNavTab.cities, 'Ciudades'),
              const SizedBox(width: 8),
              _buildNavButton(
                AdminNavTab.pointsOfInterest,
                'Puntos de interés',
              ),
              const SizedBox(width: 8),
              _buildNavButton(AdminNavTab.missions, 'Misiones'),
              const SizedBox(width: 8),
              _buildNavButton(AdminNavTab.routes, 'Rutas'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(AdminNavTab tab, String label) {
    final isActive = tab == activeTab;

    return OutlinedButton(
      onPressed: () => onTabChanged(tab),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isActive ? AppColors.grisInput : AppColors.grisClaro,
          width: isActive ? 2 : 1,
        ),
        foregroundColor: isActive ? AppColors.blancoTexto : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: isActive ? AppColors.exito : Colors.transparent,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
