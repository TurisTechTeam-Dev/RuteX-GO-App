import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // línea superior
            Container(
              height: 2,
              color: Colors.black,
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: Colors.amber,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "¡Ruta Monumental\nCompletada!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.verdePrincipal,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _statCard("Puntuación", "100/100"),
                      const SizedBox(height: 10),

                      _statCard("Monumentos visitados", "6/6"),
                      const SizedBox(height: 10),

                      _statCard("Tiempo", "1 hora 53 minutos"),

                      const SizedBox(height: 30),

                      // VER RESULTADOS
                      _button(
                        "Ver resultados",
                        Colors.green.shade400,
                            () {
                          Navigator.pushNamed(
                              context, "/route_questions_result");
                        },
                      ),

                      const SizedBox(height: 12),

                      // COMPARTIR
                      _button(
                        "Compartir",
                        Colors.green.shade300,
                        null, // deshabilitado
                      ),

                      const SizedBox(height: 12),

                      // FINALIZAR
                      _button(
                        "Finalizar ruta",
                        Colors.green.shade800,
                            () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // línea inferior
            Container(
              height: 2,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$title: $value",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback? onPressed) {
    return SizedBox(
      width: 180,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}