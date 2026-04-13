import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/buttons/custom_button.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const QuizScreen({super.key, required this.data});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? selectedOption;
  int puntosTotales = 0;
  bool isSaving = false;
  static int _monumentosVisitados = 0;
  static int _puntosRuta = 0;
  static String? _activeRouteId;

  String? get _routeId => widget.data['routeId']?.toString() ?? _activeRouteId;

  int get _monumentosObjetivo {
    final totalPois = widget.data['totalPois'];

    if (totalPois is int && totalPois > 0) return totalPois;
    if (totalPois is num && totalPois > 0) return totalPois.toInt();
    if (totalPois is String) return int.tryParse(totalPois) ?? 3;

    return 3;
  }

  Map<String, dynamic> get _missionData {
    final mision = widget.data['mision'];

    if (mision is Map) {
      return Map<String, dynamic>.from(mision);
    }

    return widget.data;
  }

  @override
  void initState() {
    super.initState();

    final routeId = _routeId;
    if (routeId != null && routeId != _activeRouteId) {
      _activeRouteId = routeId;
      _monumentosVisitados = 0;
      _puntosRuta = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _missionData;

    if (data['preguntas'] == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.verdePrincipal),
        ),
      );
    }

    final List<dynamic> preguntas = data['preguntas'];
    final Map<String, dynamic> preguntaData = preguntas[_currentIndex];

    String textoPregunta = "Cargando...";
    Map<int, String> opciones = {};

    final int correctIndex = preguntaData['indice_correcto'] ?? 0;

    textoPregunta = preguntaData.entries
        .firstWhere((e) => e.key.startsWith('pregunta_'))
        .value
        .toString();

    final List<dynamic> respuestas = preguntaData['respuestas'] ?? [];

    for (int i = 0; i < respuestas.length; i++) {
      opciones[i] = respuestas[i].toString();
    }

    final sortedKeys = opciones.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          data['titulo'] ?? "Misión",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: isSaving
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.verdePrincipal),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / preguntas.length,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.verdePrincipal,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        "${_currentIndex + 1} de ${preguntas.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      textoPregunta,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    ...sortedKeys.map((id) {
                      bool isSelected = selectedOption == id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedOption = id;
                            });
                          },

                          borderRadius: BorderRadius.circular(14),

                          child: Container(
                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.white,

                              border: Border.all(
                                color: isSelected
                                    ? AppColors.verdePrincipal
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isSelected
                                      ? AppColors.verdePrincipal
                                      : Colors.grey.shade200,
                                  child: Text(
                                    String.fromCharCode(65 + id),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Text(
                                    opciones[id]!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const Spacer(),

                    CustomButton(
                      text: _currentIndex < preguntas.length - 1
                          ? "SIGUIENTE"
                          : "FINALIZAR",
                      onPressed: selectedOption != null
                          ? () {
                              if (selectedOption == correctIndex) {
                                puntosTotales += 10;
                              }

                              if (_currentIndex < preguntas.length - 1) {
                                setState(() {
                                  _currentIndex++;
                                  selectedOption = null;
                                });
                              } else {
                                _finalizarQuiz();
                              }
                            }
                          : null,
                    ),

                    const SizedBox(height: 15),

                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: AppColors.negroTexto,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }

  Future<void> _finalizarQuiz() async {
    _monumentosVisitados++;
    _puntosRuta += puntosTotales;
    setState(() => isSaving = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final monumentosObjetivo = await _resolveMonumentosObjetivo();

    if (_monumentosVisitados < monumentosObjetivo) {
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.missionQrScanner,
        arguments: {
          'routeId': _routeId,
          'totalPois': monumentosObjetivo,
        },
      );
    } else {
      final routeId = _routeId;
      if (routeId != null && routeId.isNotEmpty) {
        try {
          await _markRouteAsCompleted(routeId, monumentosObjetivo);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("No se pudo guardar la ruta: $e"),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      _monumentosVisitados = 0;
      _puntosRuta = 0;
      _activeRouteId = null;

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  Future<int> _resolveMonumentosObjetivo() async {
    final routeId = _routeId;
    if (routeId == null || routeId.isEmpty) return _monumentosObjetivo;

    final routeDoc = await FirebaseFirestore.instance
        .collection('rutas')
        .doc(routeId)
        .get();
    final data = routeDoc.data();
    final puntosInteres = data?['id_puntos_interes'];

    if (puntosInteres is List && puntosInteres.isNotEmpty) {
      return puntosInteres.length;
    }

    return _monumentosObjetivo;
  }

  Future<void> _markRouteAsCompleted(
    String routeId,
    int monumentosVisitados,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? {};
      final completedRoutes = List<dynamic>.from(
        data['rutas_completadas'] ?? [],
      );

      final hasDetailedCompletion = completedRoutes.any((route) {
        if (route is Map) {
          final savedRouteId =
              route['rutaId'] ?? route['id_ruta'] ?? route['routeId'];
          return savedRouteId?.toString() == routeId;
        }

        return false;
      });

      if (hasDetailedCompletion) return;

      final hasLegacyCompletion = completedRoutes.any(
        (route) => route is String && route == routeId,
      );

      final updates = <String, dynamic>{
        'rutas_completadas': FieldValue.arrayUnion([
          {
            'rutaId': routeId,
            'puntos_obtenidos': _puntosRuta,
            'monumentos_visitados': monumentosVisitados,
            'misiones_completadas': monumentosVisitados,
          },
        ]),
      };

      if (!hasLegacyCompletion) {
        updates['puntos'] = FieldValue.increment(_puntosRuta);
      }

      transaction.update(userRef, updates);
    });
  }
}
