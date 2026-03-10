import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/Bars/toppAppBarr.dart';
import 'package:mobile_app/features/profile/data/profile_remote_datasource.dart';
import 'package:mobile_app/features/profile/data/profile_repository_impl.dart';
import 'package:mobile_app/features/profile/domain/usecases/profile_uses_cases.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/cards/custom_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileUsesCases _profileUsesCases;
  late final ProfileRepositoryImpl repository;

  late Future<Map<String, dynamic>> userFuture;
  late Future<List<Map<String, dynamic>>> routesFuture;
  late Future<Map<String, dynamic>> rangosFuture;

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;
    final remote = ProfileRemoteDatasource(firestore);
    repository = ProfileRepositoryImpl(remote);

    _profileUsesCases = ProfileUsesCases(repository);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    userFuture = _profileUsesCases.getUserProfile(uid);
    routesFuture = _profileUsesCases.getCompletedRoutes(uid);
    rangosFuture = _profileUsesCases.getConfigRangos("3CpvEa6pk5fvifbr73jW");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: const TopAppBar(),

      drawer: const CustomDrawer(),

      // --- TU CONTENIDO SIGUE IGUAL ---
      body: FutureBuilder<Map<String, dynamic>>(
        future: userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError || !userSnapshot.hasData) {
            return const Center(child: Text("Error al cargar el usuario"));
          }

          final userData = userSnapshot.data!;

          return FutureBuilder<Map<String, dynamic>>(
            future: rangosFuture,
            builder: (context, rangosSnapshot) {
              if (rangosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (rangosSnapshot.hasError || !rangosSnapshot.hasData) {
                return const Center(child: Text("Error al cargar los rangos"));
              }
              final rangosData = rangosSnapshot.data!;

              final nombreRango = _calcularNombreRango(
                userData['puntos'] ?? 0,
                rangosData['rangos'],
              );

              return Stack(
                children: [
                  // FONDO
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Mapa_Fondo_Extremadura.jpeg'),
                        opacity: 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Línea superior
                        Container(height: 2, color: AppColors.negroTexto),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pasamos el nombre calculado
                              _userCard(userData, nombreRango),
                              const SizedBox(height: 20),

                              const StrokeTitle(text: "Estadísticas"),
                              const SizedBox(height: 12),

                              _statsCard(userData),
                              const SizedBox(height: 20),

                              const StrokeTitle(text: "Rutas Completadas"),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView(
                              children: [
                                _routeCard(
                                  title: "Ruta Romana (Mérida)",
                                  missions: "1/3",
                                  date: "08/10/2025",
                                  points: "100 pts",
                                ),
                                const SizedBox(height: 12),
                                _routeCard(
                                  title: "Ruta Cotidiana (Mérida)",
                                  missions: "2/3",
                                  date: "15/10/2025",
                                  points: "100 pts",
                                ),
                                const SizedBox(height: 12),
                                _routeCard(
                                  title: "Ruta Imperial (Mérida)",
                                  missions: "3/3",
                                  date: "22/10/2025",
                                  points: "150 pts",
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),

                        // Línea inferior
                        Container(height: 2, color: AppColors.negroTexto),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.verdePrincipal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.citySelection,
                                  );
                                },
                                child: const Text(
                                  "¡Visitar!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blancoPuro,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // MÉTODOS DE UI SE MANTIENEN IGUAL
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

  static Widget _statsCard(Map<String, dynamic> userData) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rutas completadas: ${(userData['rutas_completadas'] as List?)?.length ?? 0}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Misiones: 6/6",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Puntos totales: 480",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Monumentos visitados: 6",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Medallas: 3",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _routeCard({
    required String title,
    required String missions,
    required String date,
    required String points,
  }) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title - $points",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Misiones: $missions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Ruta completada: $date",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.negroTexto,
            ),
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
          // Borde verde
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

          // Texto negro
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
