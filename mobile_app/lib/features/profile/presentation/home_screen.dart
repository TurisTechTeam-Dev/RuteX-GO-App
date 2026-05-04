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
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/widgets/app_info_dialog.dart';
import '../../../app/widgets/custom_drawer.dart';
import '../../../app/widgets/top_app_bar.dart';
import '../../../core/widgets/audio_guide/audio_guide.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../data/cache/home_data_cache.dart';
import '../domain/entities/home_data.dart';
import '../domain/usecases/profile_use_cases.dart';
import 'models/home_summary.dart';
import 'widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  final bool showInfoOnStart;

  const HomeScreen({super.key, this.showInfoOnStart = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<_HomeLoadResult> homeFuture = _loadHomeData();
  final HomeDataCache _homeDataCache = const HomeDataCache();
  bool _infoDialogShown = false;

  @override
  void initState() {
    super.initState();
    _showInfoDialogIfNeeded();
  }

  Future<_HomeLoadResult> _loadHomeData() async {
    final user = context.read<AuthUseCases>().getCurrentUser();
    if (user == null) {
      throw Exception("No hay sesión activa.");
    }

    final profileUseCases = context.read<ProfileUseCases>();

    try {
      final data = await profileUseCases
          .getHomeData(user.uid)
          .timeout(const Duration(seconds: 6));
      await _homeDataCache.save(user.uid, data);

      return _HomeLoadResult(data: data, isOffline: false);
    } catch (_) {
      final cachedData = await _homeDataCache.read(user.uid);
      if (cachedData != null) {
        return _HomeLoadResult(data: cachedData, isOffline: true);
      }

      rethrow;
    }
  }

  String _buildAudioGuideText(HomeData data) {
    final summary = HomeSummary.fromHomeData(data);
    final name = data.user.name.trim().isEmpty ? 'explorador' : data.user.name;
    final routesText = data.routes.isEmpty
        ? 'Aún no tienes rutas completadas.'
        : data.routes
              .map(
                (route) =>
                    '${route.name}: ${route.completedMissions} de ${route.totalMissions} misiones completadas.',
              )
              .join(' ');

    return 'Hola $name. Estás en la pantalla principal. Tu rango actual es ${summary.rankName}. Tienes ${summary.totalPoints} puntos y has completado ${summary.completedRoutes} rutas. $routesText En la esquina inferior derecha tienes el botón explorar para descubrir nuevas rutas culturales.';
  }

  void _showInfoDialogIfNeeded() {
    if (!widget.showInfoOnStart || _infoDialogShown) {
      return;
    }

    _infoDialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(context: context, builder: (_) => const AppInfoDialog());
    });
  }

  @override
  Widget build(BuildContext context) {
    final autoRead = MediaQuery.of(context).accessibleNavigation;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TopAppBar(),
      endDrawer: const CustomDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<_HomeLoadResult>(
        future: homeFuture,
        builder: (context, snapshot) {
          final data = snapshot.data?.data;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (data != null)
                  AudioGuideWidget(
                    text: _buildAudioGuideText(data),
                    autoRead: autoRead,
                    semanticLabel:
                        'Botón de audioguía. Pulsa para escuchar el resumen de tu perfil y la descripción de la pantalla.',
                  )
                else
                  const SizedBox(width: 56, height: 56),
                FloatingActionButton(
                  heroTag: "fab_explorar",
                  backgroundColor: AppColors.verdePrincipal,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.citySelection);
                  },
                  child: const Icon(Icons.explore, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
      body: FutureBuilder<_HomeLoadResult>(
        future: homeFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: AppColors.verdePrincipal,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No se pudo cargar el home.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grisNeutro),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;

          return HomeContent(
            data: result.data,
            showOfflineBanner: result.isOffline,
          );
        },
      ),
    );
  }
}

class _HomeLoadResult {
  final HomeData data;
  final bool isOffline;

  const _HomeLoadResult({required this.data, required this.isOffline});
}
