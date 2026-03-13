import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/buttons/custom_button.dart';

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

    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    final Map<String, dynamic>? data =
    (args is Map<String, dynamic>) ? args : null;

    if (data == null || data['preguntas'] == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B6A41)),
        ),
      );
    }

    final List<dynamic> preguntas = data['preguntas'];
    final Map<String, dynamic> preguntaData = preguntas[_currentIndex];

    String textoPregunta = "Cargando...";
    Map<int, String> opciones = {};
    final int correctIndex = preguntaData['indice_correcto'] ?? 0;

    preguntaData.forEach((key, value) {
      if (key.toString().startsWith('pregunta_')) {
        textoPregunta = value.toString();
      } else if (key.toString().startsWith('respuesta_')) {
        int? id = int.tryParse(key.toString().split('_').last);
        if (id != null) {
          opciones[id] = value.toString();
        }
      }
    });

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
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // BARRA DE PROGRESO MEJORADA
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: (_currentIndex + 1) / preguntas.length,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF1B6A41),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Pregunta ${_currentIndex + 1} de ${preguntas.length}",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // PREGUNTA
            Text(
              textoPregunta,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // RESPUESTAS
            ...sortedKeys.map((id) {
              bool isSelected = selectedOption == id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: InkWell(
                  onTap: () => setState(() => selectedOption = id),
                  borderRadius: BorderRadius.circular(14),

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [

                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected
                              ? const Color(0xFF1B6A41)
                              : Colors.grey[200],
                          child: Text(
                            String.fromCharCode(64 + id),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

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

            const SizedBox(height: 10),

            // BOTÓN
            CustomButton(
              text: _currentIndex < preguntas.length - 1
                  ? "SIGUIENTE"
                  : "FINALIZAR",
              onPressed: selectedOption != null
                  ? () async {

                if (selectedOption == correctIndex) {
                  puntosTotales += 10;
                }

                if (_currentIndex < preguntas.length - 1) {
                  setState(() {
                    _currentIndex++;
                    selectedOption = null;
                  });
                } else {
                  _finalizarQuiz(data['id'] ?? "mision_generica");
                }
              }
                  : null,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finalizarQuiz(String misionId) async {

    setState(() => isSaving = true);

    try {

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.routeResult);
      }

    } catch (e) {

      debugPrint("Error al guardar: $e");
      setState(() => isSaving = false);

    }
  }
}