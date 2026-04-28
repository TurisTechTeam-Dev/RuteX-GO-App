import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cómo funciona RuteXGo"),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoBullet(
              bold: "Ruta: ",
              text:
                  "elige una ciudad, selecciona una ruta y sigue el mapa hasta cada punto de interés.",
            ),
            SizedBox(height: 10),
            _InfoBullet(
              bold: "QR y misión: ",
              text:
                  "al llegar, escanea el QR del punto correcto. Verás una descripción del monumento y después una misión con preguntas.",
            ),
            SizedBox(height: 10),
            _InfoBullet(
              bold: "Puntos: ",
              text:
                  "cada pregunta acertada suma 10 puntos. Cada punto de interés puede dar hasta 30 puntos.",
            ),
            SizedBox(height: 10),
            _InfoBullet(
              bold: "Bonificación: ",
              text:
                  "si completas las misiones de todos los puntos de la ruta, recibes 10 puntos extra.",
            ),
            SizedBox(height: 10),
            _InfoBullet(
              bold: "Saltos: ",
              text:
                  "puedes saltar un punto, pero esa misión quedará como no realizada y no contará para la bonificación.",
            ),
            SizedBox(height: 10),
            _InfoBullet(
              bold: "Mejor marca: ",
              text: "si repites una ruta, se conserva tu mejor puntuación.",
            ),
            SizedBox(height: 10),
            _InfoBullet(
              bold: "Rango: ",
              text:
                  "tu rango se calcula con los puntos reales obtenidos en tus rutas completadas.",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Entendido"),
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String bold;
  final String text;

  const _InfoBullet({required this.bold, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.verdePrincipal,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.negroTexto,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: bold,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
