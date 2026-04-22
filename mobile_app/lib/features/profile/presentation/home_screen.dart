import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../data/home_data.dart';
import '../data/home_data_loader.dart';
import 'widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<HomeData> homeFuture = const HomeDataLoader().load();

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
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: AppColors.verdePrincipal,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No se pudo cargar el home.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.negroTexto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grisNeutro),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return HomeContent(data: snapshot.data!);
        },
      ),
    );
  }
}
