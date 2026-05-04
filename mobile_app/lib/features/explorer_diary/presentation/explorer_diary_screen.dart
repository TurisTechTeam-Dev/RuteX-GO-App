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

    return 'Diario del explorador. Selecciona las rutas que quieres incluir. La previsualización muestra una portada horizontal, una página por cada ruta seleccionada y una página final motivadora.';
  }

  @override
  Widget build(BuildContext context) {
    final autoRead = MediaQuery.of(context).accessibleNavigation;
    final isCompactHeight = MediaQuery.sizeOf(context).height < 700;
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
              compact: isCompactHeight,
            ),
            SizedBox(height: isCompactHeight ? 4 : 8),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: selectedRoutes.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _DiaryCover(userName: _userName);
                  }

                  if (index == selectedRoutes.length + 1) {
                    return const _DiaryFinalPage();
                  }

                  final route = selectedRoutes[index - 1];
                  return _DiaryRoutePage(
                    route: route,
                    userName: _userName,
                    onPickPhotos: () => _pickPhotosForRoute(route.routeId),
                  );
                },
              ),
            ),
            SizedBox(height: isCompactHeight ? 4 : 8),
            _buildActionButtons(selectedRoutes, compact: isCompactHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    List<DiaryEntry> selectedRoutes, {
    required bool compact,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, compact ? 8 : 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("DESCARGAR MI DIARIO"),
        onPressed: selectedRoutes.isEmpty
            ? null
            : () => PdfGenerator.generateExplorerBook(
                context: context,
                allRoutes: selectedRoutes,
                userName: _userName,
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.grisSombra,
          minimumSize: Size(double.infinity, compact ? 46 : 50),
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
  final bool compact;

  const _RouteSelectionPanel({
    required this.routes,
    required this.selectedRouteIds,
    required this.onChanged,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(20, compact ? 6 : 12, 20, 0),
      padding: EdgeInsets.fromLTRB(14, compact ? 8 : 12, 14, compact ? 6 : 8),
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
          SizedBox(height: compact ? 4 : 8),
          SizedBox(
            height: compact ? 64 : 96,
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

  const _DiaryCover({required this.userName});

  @override
  Widget build(BuildContext context) {
    return _DiarySheet(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/Logo_Color_Rutexgo.png', height: 138),
          const SizedBox(height: 34),
          const Text(
            'MI DIARIO DEL EXPLORADOR',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Container(height: 1.5, width: 280, color: Colors.black54),
          const SizedBox(height: 18),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 32),
          const Text(
            'Extremadura en tus manos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
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
  final VoidCallback onPickPhotos;

  const _DiaryRoutePage({
    required this.route,
    required this.userName,
    required this.onPickPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final photos = route.photos.take(4).toList();

    return Stack(
      children: [
        _DiarySheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _RoutePageHeader(),
              const SizedBox(height: 26),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _RouteStoryBlock(
                        routeName: route.routeName,
                        monuments: route.monuments,
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      flex: 5,
                      child: _MemoryMosaic(
                        photos: photos,
                        onPickPhotos: onPickPhotos,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            heroTag: 'diary-photos-${route.routeId}',
            onPressed: onPickPhotos,
            backgroundColor: AppColors.verdePrincipal,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_a_photo),
            label: Text(photos.isEmpty ? 'Añadir fotos' : '${photos.length}/4'),
          ),
        ),
      ],
    );
  }
}

class _DiarySheet extends StatelessWidget {
  final Widget child;

  const _DiarySheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 842,
          height: 595,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(44),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2DE),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PreviewActionButton extends StatelessWidget {
  final String routeId;
  final int photoCount;
  final VoidCallback onPressed;

  const PreviewActionButton({
    super.key,
    required this.routeId,
    required this.photoCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: photoCount == 0
          ? 'Añadir fotos a esta ruta'
          : 'Cambiar fotos de esta ruta. $photoCount de 4 seleccionadas',
      child: FloatingActionButton.extended(
        heroTag: 'diary-photos-$routeId',
        onPressed: onPressed,
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo),
        label: Text(photoCount == 0 ? 'Añadir fotos' : '$photoCount/4'),
      ),
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
            'DIARIO DEL EXPLORADOR',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        Image.asset('assets/Logo_Color_Rutexgo.png', height: 52),
      ],
    );
  }
}

class _RouteStoryBlock extends StatelessWidget {
  final String routeName;
  final List<String> monuments;

  const _RouteStoryBlock({
    required this.routeName,
    required this.monuments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Puntos de interés de la ruta',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        if (monuments.isNotEmpty)
          Text(
            monuments.take(5).join(' · '),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        const Spacer(),
        _RouteMedalPreview(routeName: routeName),
        const Spacer(),
      ],
    );
  }
}

class _RouteMedalPreview extends StatelessWidget {
  final String routeName;

  const _RouteMedalPreview({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/Sello_ruta_monumental_romana.png',
          width: 178,
          height: 178,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          routeName.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF6D5F2E), fontSize: 10),
        ),
      ],
    );
  }
}

class ExplorerDataBlock extends StatelessWidget {
  final String userName;
  final String routeName;
  final List<String> monuments;

  const ExplorerDataBlock({
    super.key,
    required this.userName,
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
        const SizedBox(height: 14),
        Center(child: RouteMedal(routeName: routeName)),
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

class RouteMedal extends StatelessWidget {
  final String routeName;

  const RouteMedal({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/Sello_Monumental_Romana.png',
          width: 132,
          height: 132,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        Text(
          routeName.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF6D5F2E), fontSize: 9),
        ),
      ],
    );
  }
}

class _MemoryMosaic extends StatelessWidget {
  final List<File> photos;
  final VoidCallback onPickPhotos;

  const _MemoryMosaic({required this.photos, required this.onPickPhotos});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _RomanPhotoFramePainter()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(4),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.03,
            ),
            itemBuilder: (context, index) {
              final file = index < photos.length ? photos[index] : null;
              return _MemoryTile(
                file: file,
                index: index,
                onTap: onPickPhotos,
                tilt: _photoTilts[index],
              );
            },
          ),
        ),
      ],
    );
  }

  static const List<double> _photoTilts = [-0.025, 0.018, 0.022, -0.018];
}

class _RomanPhotoFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFC9A227).withValues(alpha: 0.38)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = const Color(0xFFC9A227).withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(10, 22), Offset(size.width - 10, 22), linePaint);
    canvas.drawLine(
      Offset(10, size.height - 22),
      Offset(size.width - 10, size.height - 22),
      linePaint,
    );

    for (final x in [10.0, size.width - 24]) {
      canvas.drawRect(Rect.fromLTWH(x, 44, 14, size.height - 88), linePaint);
      canvas.drawRect(Rect.fromLTWH(x - 5, 34, 24, 8), fillPaint);
      canvas.drawRect(Rect.fromLTWH(x - 5, size.height - 42, 24, 8), fillPaint);
    }

    for (var i = 0; i < 9; i++) {
      final x = 44.0 + (i * 26);
      if (x > size.width - 44) break;
      canvas.drawCircle(Offset(x, 22), 3, fillPaint);
      canvas.drawCircle(Offset(x, size.height - 22), 3, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MemoryTile extends StatelessWidget {
  final File? file;
  final int index;
  final VoidCallback onTap;
  final double tilt;

  const _MemoryTile({
    required this.file,
    required this.index,
    required this.onTap,
    required this.tilt,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFE5D8B4), width: 1.4),
        ),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: file == null
                        ? Container(
                            color: const Color(0xFFF0F0F0),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                  size: 34,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  index == 0
                                      ? 'Añadir fotos'
                                      : 'Recuerdo ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.file(
                              file!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const Positioned(
                    left: 10,
                    top: 8,
                    child: _TapeStrip(rotation: -0.08),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapeStrip extends StatelessWidget {
  final double rotation;

  const _TapeStrip({this.rotation = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 42,
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3B0).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFE1C66D), width: 0.6),
        ),
      ),
    );
  }
}

class _DiaryFinalPage extends StatelessWidget {
  const _DiaryFinalPage();

  @override
  Widget build(BuildContext context) {
    return _DiarySheet(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Logo_Color_Rutexgo.png', height: 82),
              const SizedBox(height: 24),
              const Text(
                'Cada ruta que completas deja una huella en tu historia.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              const Text(
                'Sigue explorando, observando y descubriendo Extremadura.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
