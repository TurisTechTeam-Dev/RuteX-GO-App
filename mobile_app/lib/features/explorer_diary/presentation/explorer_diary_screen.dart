/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/audio_guide/audio_guide.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../../profile/domain/usecases/profile_use_cases.dart';
import '../../profile/presentation/models/home_summary.dart';
import '../domain/entities/diary_entry.dart';
import '../domain/usecases/diary_use_cases.dart';
import 'utils/pdf_generator.dart';

class ExplorerDiaryScreen extends StatefulWidget {
  const ExplorerDiaryScreen({super.key});

  @override
  State<ExplorerDiaryScreen> createState() => _ExplorerDiaryScreenState();
}

class _ExplorerDiaryScreenState extends State<ExplorerDiaryScreen> {
  static const int _maxPhotosPerRoute = 4;

  final PageController _pageController = PageController(viewportFraction: 0.88);
  final ImagePicker _picker = ImagePicker();

  List<DiaryEntry>? _completedRoutes;
  final Set<String> _selectedRouteIds = <String>{};
  String _userName = 'Explorador';
  String _userRank = 'Explorador';
  bool _isLoading = true;

  List<DiaryEntry> get _selectedRoutes {
    final routes = _completedRoutes ?? const <DiaryEntry>[];
    return routes
        .where((route) => _selectedRouteIds.contains(route.routeId))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authUseCases = context.read<AuthUseCases>();
    final diaryUseCases = context.read<DiaryUseCases>();
    final profileUseCases = context.read<ProfileUseCases>();
    final currentUser = authUseCases.getCurrentUser();
    final userId = currentUser?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      debugPrint("Error: No se encontró una sesión activa");
      return;
    }

    try {
      final results = await Future.wait([
        diaryUseCases.executeGetCompletedRoutes(userId),
        profileUseCases.getHomeData(userId),
      ]);
      final routes = results[0] as List<DiaryEntry>;
      final homeData = results[1] as dynamic;
      final summary = HomeSummary.fromHomeData(homeData);
      final user = homeData.user;
      final displayName = user.username.toString().isNotEmpty
          ? user.username.toString()
          : user.name.toString();

      setState(() {
        _completedRoutes = routes;
        _selectedRouteIds
          ..clear()
          ..addAll(routes.map((route) => route.routeId));
        _userName = displayName.isNotEmpty ? displayName : 'Explorador';
        _userRank = summary.rankName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error al cargar diario: $e");
    }
  }

  Future<void> _pickPhotosForRoute(String routeId) async {
    final pickedImages = await _picker.pickMultiImage(
      limit: _maxPhotosPerRoute,
    );
    if (pickedImages.isEmpty) return;

    final selectedPhotos = pickedImages
        .take(_maxPhotosPerRoute)
        .map((xFile) => File(xFile.path))
        .toList(growable: false);

    setState(() {
      _completedRoutes = (_completedRoutes ?? const <DiaryEntry>[])
          .map(
            (route) => route.routeId == routeId
                ? route.copyWith(photos: selectedPhotos)
                : route,
          )
          .toList(growable: false);
    });

    if (pickedImages.length > _maxPhotosPerRoute && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes añadir 4 fotos por ruta.')),
      );
    }
  }

  void _toggleRoute(String routeId, bool selected) {
    setState(() {
      if (selected) {
        _selectedRouteIds.add(routeId);
      } else {
        _selectedRouteIds.remove(routeId);
      }
    });
  }

  String _buildAudioGuideText() {
    final routes = _completedRoutes ?? const <DiaryEntry>[];

    if (_isLoading) {
      return 'Diario del explorador. Estamos cargando tus rutas completadas.';
    }

    if (routes.isEmpty) {
      return 'Diario del explorador. Aún no tienes rutas completadas. Completa una ruta para crear nuevas páginas de tu diario.';
    }

    return 'Diario del explorador. Selecciona las rutas que quieres incluir. La previsualización muestra una portada y una página vertical por cada ruta seleccionada.';
  }

  @override
  Widget build(BuildContext context) {
    final autoRead = MediaQuery.of(context).accessibleNavigation;
    final audioGuide = AudioGuideWidget(
      text: _buildAudioGuideText(),
      autoRead: autoRead,
      semanticLabel:
          'Botón de audioguía. Pulsa para escuchar la descripción del diario del explorador.',
    );

    if (_isLoading) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: audioGuide,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_completedRoutes == null || _completedRoutes!.isEmpty) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: audioGuide,
        body: const Center(child: Text("No tienes rutas completadas aún.")),
      );
    }

    final selectedRoutes = _selectedRoutes;

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Diario de Explorador")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: audioGuide,
      body: SafeArea(
        child: Column(
          children: [
            _RouteSelectionPanel(
              routes: _completedRoutes!,
              selectedRouteIds: _selectedRouteIds,
              onChanged: _toggleRoute,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: selectedRoutes.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _DiaryCover(userName: _userName, userRank: _userRank);
                  }

                  final route = selectedRoutes[index - 1];
                  return _DiaryRoutePage(
                    route: route,
                    userName: _userName,
                    userRank: _userRank,
                    onPickPhotos: () => _pickPhotosForRoute(route.routeId),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildActionButtons(selectedRoutes),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(List<DiaryEntry> selectedRoutes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("DESCARGAR MI DIARIO"),
        onPressed: selectedRoutes.isEmpty
            ? null
            : () => PdfGenerator.generateExplorerBook(
                context: context,
                allRoutes: selectedRoutes,
                userName: _userName,
                userRank: _userRank,
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.grisSombra,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _RouteSelectionPanel extends StatelessWidget {
  final List<DiaryEntry> routes;
  final Set<String> selectedRouteIds;
  final void Function(String routeId, bool selected) onChanged;

  const _RouteSelectionPanel({
    required this.routes,
    required this.selectedRouteIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.negroTexto, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rutas que aparecerán en tu diario',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: ListView.separated(
              itemCount: routes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final route = routes[index];
                final selected = selectedRouteIds.contains(route.routeId);

                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: selected,
                  title: Text(
                    route.routeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.verdePrincipal,
                  onChanged: (value) =>
                      onChanged(route.routeId, value ?? false),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryCover extends StatelessWidget {
  final String userName;
  final String userRank;

  const _DiaryCover({required this.userName, required this.userRank});

  @override
  Widget build(BuildContext context) {
    return _DiarySheet(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/Logo_Color_Rutexgo.png', height: 74),
          const SizedBox(height: 28),
          const Text(
            'MI DIARIO DE\nEXPLORADOR',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          const Divider(indent: 48, endIndent: 48, color: Colors.black54),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('Rango: $userRank', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 36),
          const Text(
            'Extremadura en tus manos',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryRoutePage extends StatelessWidget {
  final DiaryEntry route;
  final String userName;
  final String userRank;
  final VoidCallback onPickPhotos;

  const _DiaryRoutePage({
    required this.route,
    required this.userName,
    required this.userRank,
    required this.onPickPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final photos = route.photos.take(4).toList();

    return _DiarySheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RoutePageHeader(),
          const SizedBox(height: 16),
          _ExplorerDataBlock(
            userName: userName,
            userRank: userRank,
            routeName: route.routeName,
            monuments: route.monuments,
          ),
          const SizedBox(height: 16),
          const Text(
            'MIS RECUERDOS',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.86,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final file = index < photos.length ? photos[index] : null;
                return _MemoryTile(
                  file: file,
                  index: index,
                  onTap: onPickPhotos,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onPickPhotos,
            icon: const Icon(Icons.add_a_photo, size: 18),
            label: Text(
              photos.isEmpty ? 'Añadir 4 fotos' : 'Cambiar fotos (${photos.length}/4)',
            ),
          ),
        ],
      ),
    );
  }
}

class _DiarySheet extends StatelessWidget {
  final Widget child;

  const _DiarySheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2DE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3DCC4), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RoutePageHeader extends StatelessWidget {
  const _RoutePageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/Mapa_fondo_Extremadura.png', height: 38),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'DIARIO DEL\nEXPLORADOR',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ExplorerDataBlock extends StatelessWidget {
  final String userName;
  final String userRank;
  final String routeName;
  final List<String> monuments;

  const _ExplorerDataBlock({
    required this.userName,
    required this.userRank,
    required this.routeName,
    required this.monuments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos del Explorador',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text('Nombre: $userName'),
        Text('Rango: $userRank'),
        const SizedBox(height: 14),
        Center(child: _RouteMedal(routeName: routeName)),
        if (monuments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            monuments.take(4).join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ],
    );
  }
}

class _RouteMedal extends StatelessWidget {
  final String routeName;

  const _RouteMedal({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF7D6),
        border: Border.all(color: const Color(0xFFC9A227), width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RUTA',
              style: TextStyle(
                color: Color(0xFF8A6A00),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFD4AF37),
              size: 36,
            ),
            const Text(
              'COMPLETADA',
              style: TextStyle(
                color: Color(0xFF8A6A00),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              routeName.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF8A6A00), fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  final File? file;
  final int index;
  final VoidCallback onTap;

  const _MemoryTile({
    required this.file,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Expanded(
                child: file == null
                    ? Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, color: Colors.grey),
                        ),
                      )
                    : Image.file(file!, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 4),
              Text(
                file == null ? 'Recuerdo ${index + 1}' : 'Foto ${index + 1}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
