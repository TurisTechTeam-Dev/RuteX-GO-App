import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/cards/custom_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "RuteX Go",
          style: TextStyle(
            color: AppColors.verdePrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.verdePrincipal),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [

          // 🔹 FONDO IGUAL QUE LOGIN
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa Fondo Extremadura.jpeg'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🔹 CONTENIDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),

                  // CARD USUARIO
                  _userCard(),

                  const SizedBox(height: 20),

                  // ESTADÍSTICAS
                  const Text(
                    "Estadísticas",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _statsCard(),

                  const SizedBox(height: 20),

                  // RUTAS COMPLETADAS
                  const Text(
                    "Rutas Completadas",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdePrincipal,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔥 SOLO ESTO HACE SCROLL
                  Expanded(
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

                        // 👉 NUEVA RUTA PARA PROBAR SCROLL
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

                  // BOTÓN FIJO
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "¡Visitar!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blancoPuro,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _userCard() {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.verdePrincipal,
            child: Icon(Icons.person, color: AppColors.blancoPuro),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DiegoVP01",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.negroTexto,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Explorador novato desde Oct 2025",
                style: TextStyle(
                  color: AppColors.grisNeutro,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Rango: Legionario",
                style: TextStyle(
                  color: AppColors.verdePrincipal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _statsCard() {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rutas completadas: 2"),
          SizedBox(height: 6),
          Text("Misiones: 6/6"),
          SizedBox(height: 6),
          Text("Puntos totales: 480"),
          SizedBox(height: 6),
          Text("Monumentos visitados: 6"),
          SizedBox(height: 6),
          Text("Medallas: 3"),
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
          Text("Misiones: $missions"),
          const SizedBox(height: 6),
          Text("Ruta completada: $date"),
        ],
      ),
    );
  }
}