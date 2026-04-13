import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';
import '../../../core/widgets/cards/custom_cards.dart';

class HomeData {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> routes;
  final List<dynamic> rangos;

  HomeData({required this.user, required this.routes, required this.rangos});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<HomeData> homeFuture = _loadHomeData();

  Future<HomeData> _loadHomeData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    final userData = userDoc.data() ?? {};

    final rangosDoc = await FirebaseFirestore.instance
        .collection("config_rangos")
        .doc("3CpvEa6pk5fvifbr73jW")
        .get();

    final rangos = rangosDoc.data()?["rangos"] ?? [];

    final List<dynamic> rutasProgreso = List.from(
      userData["rutas_completadas"] ?? [],
    );

    List<String> rutasIds = rutasProgreso
        .map(_routeIdFromProgress)
        .whereType<String>()
        .toList();

    rutasIds = rutasIds.toSet().toList();

    List<Map<String, dynamic>> rutas = [];

    if (rutasIds.isNotEmpty) {
      final rutasQuery = await FirebaseFirestore.instance
          .collection("rutas")
          .where(FieldPath.documentId, whereIn: rutasIds)
          .get();

      for (var doc in rutasQuery.docs) {
        final data = doc.data();
        final puntosInteres = List.from(data["id_puntos_interes"] ?? []);
        final misionesTotales = puntosInteres.length;
        final puntosTotales = _asInt(
          data["puntos_totales"],
          defaultValue: misionesTotales * 30,
        );

        final progreso = _progressMapForRoute(rutasProgreso, doc.id);
        final hasDetailedProgress = progreso.isNotEmpty;

        final puntosObtenidos = _asInt(
          progreso["puntos_obtenidos"] ?? progreso["puntos"],
          defaultValue: hasDetailedProgress ? 0 : puntosTotales,
        );
        final misionesAcertadas = _asInt(
          progreso["misiones_acertadas"] ?? progreso["misiones_completadas"],
          defaultValue: hasDetailedProgress ? 0 : misionesTotales,
        );

        rutas.add({
          "id": doc.id,
          "nombre": data["nombre"] ?? "Ruta",
          "puntos_totales": puntosTotales,
          "id_puntos_interes": puntosInteres,
          "misiones_totales": misionesTotales,
          "puntos_obtenidos": puntosObtenidos,
          "misiones_acertadas": misionesAcertadas,
        });
      }
    }

    return HomeData(user: userData, routes: rutas, rangos: rangos);
  }

  static String? _routeIdFromProgress(dynamic progress) {
    if (progress is String) return progress;

    if (progress is Map) {
      final routeId = progress["rutaId"] ?? progress["id_ruta"] ?? progress["routeId"];
      return routeId?.toString();
    }

    return null;
  }

  static Map<String, dynamic> _progressMapForRoute(
    List<dynamic> routesProgress,
    String routeId,
  ) {
    for (final progress in routesProgress) {
      if (progress is Map && _routeIdFromProgress(progress) == routeId) {
        return Map<String, dynamic>.from(progress);
      }
    }

    return {};
  }

  static int _asInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;

    return defaultValue;
  }

  String _calcularNombreRango(int puntos, List<dynamic> listaRangos) {
    String nombre = "Esclavo";
    int puntosMax = -1;

    for (var rango in listaRangos) {
      if (puntos >= rango['puntos_necesarios'] &&
          rango['puntos_necesarios'] > puntosMax) {
        puntosMax = rango['puntos_necesarios'];
        nombre = rango['nombre'];
      }
    }

    return nombre;
  }

  int _calcularMisiones(List<Map<String, dynamic>> rutas) {
    int total = 0;

    for (var ruta in rutas) {
      final misiones = ruta["misiones_acertadas"];

      if (misiones is int) {
        total += misiones;
      }
    }

    return total;
  }

  int _calcularMisionesTotales(List<Map<String, dynamic>> rutas) {
    int total = 0;

    for (var ruta in rutas) {
      final misiones = ruta["misiones_totales"];

      if (misiones is int) {
        total += misiones;
      }
    }

    return total;
  }

  int _calcularPuntos(List<Map<String, dynamic>> rutas) {
    int total = 0;

    for (var ruta in rutas) {
      final puntos = ruta["puntos_obtenidos"];

      if (puntos is int) {
        total += puntos;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TopAppBar(),
      endDrawer: const CustomDrawer(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.verdePrincipal,
        child: const Icon(Icons.explore, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.citySelection);
        },
      ),

      body: FutureBuilder<HomeData>(
        future: homeFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          final userData = data.user;
          final rutas = data.routes;
          final rangos = data.rangos;

          final puntosTotales = _calcularPuntos(rutas);

          final nombreRango = _calcularNombreRango(puntosTotales, rangos);

          final misiones = _calcularMisiones(rutas);
          final misionesTotales = _calcularMisionesTotales(rutas);

          final rutasCompletadas = rutas.length;

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.blancoPuro,
                  image: DecorationImage(
                    image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
                    opacity: 0.4,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 2, color: AppColors.negroTexto),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _userCard(userData, nombreRango),

                          const SizedBox(height: 20),

                          const StrokeTitle(text: "Estadísticas"),

                          const SizedBox(height: 12),

                          _statsCard(
                            rutasCompletadas,
                            misiones,
                            misionesTotales,
                            puntosTotales,
                          ),

                          const SizedBox(height: 20),

                          const StrokeTitle(text: "Rutas Completadas"),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: rutas.length,

                          itemBuilder: (context, index) {
                            final ruta = rutas[index];

                            final nombre = ruta["nombre"];
                            final puntosTotales = ruta["puntos_totales"];

                            final puntosObtenidos = ruta["puntos_obtenidos"];

                            final misionesTotales =
                                ruta["misiones_totales"] ?? 0;
                            final misionesCompletadas =
                                ruta["misiones_acertadas"] ?? 0;

                            return Column(
                              children: [
                                _routeCard(
                                  title: nombre,
                                  missions:
                                      "$misionesCompletadas/$misionesTotales",
                                  date: "Ruta completada",
                                  puntosObtenidos: puntosObtenidos,
                                  puntosTotales: puntosTotales,
                                  misionesTotales: misionesTotales,
                                ),

                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    Container(height: 2, color: AppColors.negroTexto),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _userCard(Map<String, dynamic> userData, String nombreRango) {
    return CustomCard(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.verdePrincipal,
            child: Icon(Icons.person, color: AppColors.blancoPuro),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.negroTexto,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Explorador novato",
                style: TextStyle(color: AppColors.grisNeutro),
              ),

              const SizedBox(height: 4),

              Text(
                "Rango: $nombreRango",
                style: const TextStyle(color: AppColors.verdePrincipal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _statsCard(
    int rutasCompletadas,
    int misionesCompletadas,
    int misionesTotales,
    int puntosTotales,
  ) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rutas completadas: $rutasCompletadas"),

          const SizedBox(height: 6),

          Text("Misiones: $misionesCompletadas/$misionesTotales"),

          const SizedBox(height: 6),

          Text("Puntos totales: $puntosTotales"),

          const SizedBox(height: 6),

          Text("Monumentos visitados: $misionesCompletadas"),
        ],
      ),
    );
  }

  static Widget _routeCard({
    required String title,
    required String missions,
    required String date,
    required int puntosObtenidos,
    required int puntosTotales,
    required int misionesTotales,
  }) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITULO
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.verdePrincipal),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.negroTexto,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// MISIONES
          Row(
            children: [
              const Icon(Icons.track_changes, size: 18),

              const SizedBox(width: 6),

              Text("Misiones: $missions"),
            ],
          ),

          const SizedBox(height: 6),

          /// FECHA
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),

              const SizedBox(width: 6),

              Text(date),
            ],
          ),

          const SizedBox(height: 6),

          /// PUNTOS
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 18),

              const SizedBox(width: 6),

              Text("Puntos: $puntosObtenidos / $puntosTotales"),
            ],
          ),
        ],
      ),
    );
  }
}

class StrokeTitle extends StatelessWidget {
  final String text;

  const StrokeTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = AppColors.verdePrincipal,
            ),
          ),

          Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
        ],
      ),
    );
  }
}
