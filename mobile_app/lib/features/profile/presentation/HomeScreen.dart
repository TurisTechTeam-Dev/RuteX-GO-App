import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/profile/data/profile_remote_datasource.dart';
import 'package:mobile_app/features/profile/data/profile_repository_impl.dart';
import 'package:mobile_app/features/profile/domain/usecases/get_completed_routes.dart';
import 'package:mobile_app/features/profile/domain/usecases/get_user_profile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/cards/custom_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GetUserProfile getUserProfile;
  late final GetCompletedRoutes getCompletedRoutes;

  late Future<Map<String, dynamic>> userFuture;
  late Future<List<Map<String, dynamic>>> routesFuture;

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;
    final remote = ProfileRemoteDatasource(firestore);
    final repository = ProfileRepositoryImpl(remote);

    getUserProfile = GetUserProfile(repository);
    getCompletedRoutes = GetCompletedRoutes(repository);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    userFuture = getUserProfile(uid);
    routesFuture = getCompletedRoutes(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.negroTexto),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar el usuario"));
          }

          final userData = snapshot.data!;

          return Stack(
            children: [
              // 🔹 FONDO
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Mapa Fondo Extremadura.jpeg'),
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
                          _userCard(userData),
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
                            onPressed: () {},
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
      ),
    );
  }

  static Widget _userCard(Map<String, dynamic> userData) {
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
                "Rango: ${userData['rango'] ?? 'Sin rango'}",
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
