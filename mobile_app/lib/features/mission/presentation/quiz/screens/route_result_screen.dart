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

import '../../../../../core/widgets/audio_guide/audio_guide.dart';
import '../../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../../app/widgets/custom_drawer.dart';
import '../../../../../app/widgets/top_app_bar.dart';
import '../models/route_result_args.dart';
import '../models/route_result_data.dart';
import '../widgets/route_result_panel.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final autoRead = MediaQuery.of(context).accessibleNavigation;
    final args = ModalRoute.of(context)?.settings.arguments;
    final result = args is RouteResultArgs
        ? RouteResultData.fromArgs(args)
        : RouteResultData.empty();

    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: AudioGuideWidget(
        text:
            'Resultado de la ruta ${result.routeName}. Has conseguido ${result.attemptScore} puntos. Has visitado ${result.visitedMonuments} de ${result.totalPois} puntos de interés y has acertado ${result.correctAnswers} de ${result.totalAnswers} respuestas.',
        autoRead: autoRead,
        semanticLabel:
            'Botón de audioguía. Pulsa para escuchar el resultado de la ruta.',
      ),
      body: Stack(
        children: [
          const ExtremaduraMapBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: RouteResultPanel(result: result),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
