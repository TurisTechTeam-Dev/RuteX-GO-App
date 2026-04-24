import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/widgets/custom_drawer.dart';
import '../../../app/widgets/top_app_bar.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../domain/entities/home_data.dart';
import '../domain/usecases/profile_use_cases.dart';
import 'widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<HomeData> homeFuture = _loadHomeData();

  Future<HomeData> _loadHomeData() async {
    final user = context.read<AuthUseCases>().getCurrentUser();
    if (user == null) {
      throw Exception("No hay sesión activa.");
    }

    return context.read<ProfileUseCases>().getHomeData(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TopAppBar(),
      endDrawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.verdePrincipal,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.citySelection);
        },
        child: const Icon(Icons.explore, color: Colors.white),
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
