import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/custom_button.dart';

// Asegúrate de importar tu repositorio o caso de uso según tu estructura de carpetas
// import '../../domain/usecases/mission_usecases.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? selectedOption;
  int puntosTotales = 0;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    // 1. Obtener argumentos de la navegación
    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    // Extraemos la misión directamente (MonumentInfo envía la misión completa)
    final Map<String, dynamic>? data = (args is Map<String, dynamic>)
        ? args
        : null;

    // Pantalla de carga si los datos no han llegado
    if (data == null || data['preguntas'] == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B6A41)),
        ),
      );
    }

    final List<dynamic> preguntas = data['preguntas'];
    final Map<String, dynamic> preguntaData = preguntas[_currentIndex];

    // --- BLOQUE DE EXTRACCIÓN DINÁMICA (SOLUCIÓN AL FALLO) ---
    String textoPregunta = "Cargando...";
    Map<int, String> opciones = {};
    // Obtenemos el índice correcto desde Firestore (ej: 1, 2 o 3)
    final int correctIndex = preguntaData['indice_correcto'] ?? 0;

    preguntaData.forEach((key, value) {
      if (key.toString().startsWith('pregunta_')) {
        textoPregunta = value.toString();
      } else if (key.toString().startsWith('respuesta_')) {
        // Extraemos el número del nombre del campo (ej: 'respuesta_1' -> 1)
        int? id = int.tryParse(key.toString().split('_').last);
        if (id != null) {
          opciones[id] = value.toString();
        }
      }
    });

    // Ordenamos las respuestas para que siempre aparezcan 1, 2, 3...
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
              child: CircularProgressIndicator(color: Color(0xFF1B6A41)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra de progreso visual
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / preguntas.length,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF1B6A41),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    "Pregunta ${_currentIndex + 1} de ${preguntas.length}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Pregunta dinámica
                  Text(
                    textoPregunta,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Listado de respuestas dinámicas
                  ...sortedKeys.map((id) {
                    bool isSelected = selectedOption == id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => setState(() => selectedOption = id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8F5E9)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1B6A41)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: isSelected
                                    ? const Color(0xFF1B6A41)
                                    : Colors.grey[200],
                                child: Text(
                                  String.fromCharCode(64 + id),
                                  // Convierte 1 en A, 2 en B...
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
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

                  const SizedBox(height: 30),

                  // Botón Siguiente / Finalizar
                  CustomButton(
                    text: _currentIndex < preguntas.length - 1
                        ? "SIGUIENTE"
                        : "FINALIZAR",
                    onPressed: selectedOption != null
                        ? () async {
                            // Validar respuesta y sumar puntos
                            if (selectedOption == correctIndex) {
                              puntosTotales += 10;
                            }

                            if (_currentIndex < preguntas.length - 1) {
                              // Pasar a la siguiente pregunta
                              setState(() {
                                _currentIndex++;
                                selectedOption = null;
                              });
                            } else {
                              // Acción al terminar el Quiz
                              _finalizarQuiz(data['id'] ?? "mision_generica");
                            }
                          }
                        : null, // Desactivado si no hay selección
                  ),
                ],
              ),
            ),
    );
  }

  // Función para guardar resultados y salir
  Future<void> _finalizarQuiz(String misionId) async {
    setState(() => isSaving = true);

    try {
      // Aquí Joel, debes llamar a tu función de guardado:
      // await missionUseCases.saveMissionResult(
      //   userId: "ID_DE_JOEL",
      //   misionId: misionId,
      //   puntosObtenidos: puntosTotales
      // );

      // Simulación de pequeña espera para feedback visual
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context, puntosTotales);
      }
    } catch (e) {
      debugPrint("Error al guardar: $e");
      setState(() => isSaving = false);
    }
  }
}
