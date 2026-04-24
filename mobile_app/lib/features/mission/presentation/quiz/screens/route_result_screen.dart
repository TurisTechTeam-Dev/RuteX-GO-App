import 'package:flutter/material.dart';

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
    final args = ModalRoute.of(context)?.settings.arguments;
    final result = args is RouteResultArgs
        ? RouteResultData.fromArgs(args)
        : RouteResultData.empty();

    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
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
