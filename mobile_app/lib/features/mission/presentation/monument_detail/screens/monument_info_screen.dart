import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/audio_guide/audio_guide.dart';
import '../../../../../core/widgets/cards/custom_cards.dart';
import '../../../../../core/widgets/images/storage_aware_image.dart';
import '../../../../../app/navigation/app_routes.dart';
import '../../../../../app/widgets/custom_drawer.dart';
import '../../../../../app/widgets/top_app_bar.dart';
import '../../mission_flow_result.dart';
import '../../quiz/models/quiz_mission.dart';
import '../models/monument_info_args.dart';

class MonumentInfoScreen extends StatefulWidget {
  final MonumentInfoArgs args;

  const MonumentInfoScreen({super.key, required this.args});

  @override
  State<MonumentInfoScreen> createState() => _MonumentInfoScreenState();
}

class _MonumentInfoScreenState extends State<MonumentInfoScreen> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final point = widget.args.scanResult.point;
    final mission = widget.args.scanResult.mission;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const TopAppBar(showBack: true),
      drawer: const CustomDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: AudioGuideWidget(
        text:
            'Punto de interes: ${point.name}. ${point.description}. Cuando estes listo, pulsa empezar mision para responder las preguntas.',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
              ),
              child: point.image.isNotEmpty
                  ? StorageAwareImage(
                      source: point.image,
                      fit: BoxFit.cover,
                      fallback: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 80,
                          color: AppColors.verdePrincipal,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.account_balance,
                        size: 80,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      point.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.description,
                          maxLines: expanded ? null : 5,
                          overflow: expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (point.description.length > 200)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                            child: Text(
                              expanded ? "Mostrar menos" : "Mostrar más",
                              style: const TextStyle(
                                color: AppColors.verdePrincipal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrincipal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.quiz,
                          arguments: QuizMission.fromMission(
                            mission: mission,
                            routeId: widget.args.routeId,
                            pointId: point.id,
                            pointName: point.name,
                            totalPois: widget.args.totalPois,
                          ),
                        );

                        if (!context.mounted) return;

                        if (result == MissionFlowResult.pointCompleted) {
                          Navigator.pop(
                            context,
                            MissionFlowResult.pointCompleted,
                          );
                        }
                      },
                      child: const Text(
                        "EMPEZAR MISIÓN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.onSurface, width: 2),
          ),
        ),
        child: const SafeArea(child: SizedBox()),
      ),
    );
  }
}
