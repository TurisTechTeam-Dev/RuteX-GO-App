import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../data/factories/home_data_loader_factory.dart';
import '../domain/entities/home_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<HomeData> profileFuture = _loadProfileData();

  Future<HomeData> _loadProfileData() async {
    final user = context.read<AuthUseCases>().getCurrentUser();
    if (user == null) {
      throw Exception("No hay sesión activa.");
    }

    return createHomeDataLoader().load(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          const ExtremaduraMapBackground(),
          SafeArea(
            child: FutureBuilder<HomeData>(
              future: profileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ProfileError(message: snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _ProfileContent(data: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final HomeData data;

  const _ProfileContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = data.user;
    final displayName = user.username.isNotEmpty ? user.username : user.name;

    return Column(
      children: [
        Container(height: 2, color: AppColors.negroTexto),
        const SizedBox(height: 20),
        const Text(
          "Perfil de usuario",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomCard(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileRow(label: "Usuario", value: displayName),
                _ProfileRow(label: "Nombre", value: user.name),
                _ProfileRow(label: "Correo electrónico", value: user.email),
                _ProfileRow(label: "Puntos", value: user.points.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.verdePrincipal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "--" : value,
            style: const TextStyle(
              color: AppColors.negroTexto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;

  const _ProfileError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "No se pudo cargar el perfil.\n$message",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.negroTexto),
        ),
      ),
    );
  }
}
