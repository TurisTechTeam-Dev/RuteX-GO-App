/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/text_normalizer.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_form_controller.dart';

class MissionForm extends StatefulWidget {
  final AdminMissionModel? mission;
  final List<AdminPoiModel> availablePoints;
  final List<AdminMissionModel> existingMissions;
  final List<AdminCityModel> cities;
  final List<AdminRouteModel> routes;
  final AdminFormController formController;
  final ValueChanged<AdminMissionModel> onSave;

  const MissionForm({
    super.key,
    this.mission,
    required this.availablePoints,
    required this.existingMissions,
    required this.cities,
    required this.routes,
    required this.formController,
    required this.onSave,
  });

  @override
  State<MissionForm> createState() => _MissionFormState();
}

class _MissionFormState extends State<MissionForm> {
  final ScrollController _scrollController = ScrollController();

  late final TextEditingController _titleController;
  late final TextEditingController _questionOneController;
  late final TextEditingController _questionTwoController;
  late final TextEditingController _questionThreeController;
  late final List<TextEditingController> _answerControllers;
  late String? _selectedPointId;
  late String? _selectedCityId;
  late final List<int> _correctAnswers;
  Object? _formControllerToken;

  @override
  void initState() {
    super.initState();
    final questionsData =
        widget.mission?.questions ?? const <AdminMissionQuestion>[];

    _titleController = TextEditingController(text: widget.mission?.title);
    _questionOneController = TextEditingController(
      text: questionsData.isNotEmpty ? questionsData[0].text : '',
    );
    _questionTwoController = TextEditingController(
      text: questionsData.length > 1 ? questionsData[1].text : '',
    );
    _questionThreeController = TextEditingController(
      text: questionsData.length > 2 ? questionsData[2].text : '',
    );
    _answerControllers = List.generate(9, (index) {
      final questionIndex = index ~/ 3;
      final answerIndex = index % 3;
      final answers = questionIndex < questionsData.length
          ? questionsData[questionIndex].answers
          : null;
      return TextEditingController(
        text: answers != null && answerIndex < answers.length
            ? answers[answerIndex]
            : '',
      );
    });
    _correctAnswers = List<int>.generate(
      3,
      (index) =>
          index < questionsData.length ? questionsData[index].correctIndex : 0,
    );
    _selectedPointId = widget.mission?.pointId.isNotEmpty == true
        ? widget.mission!.pointId
        : null;
    _selectedCityId = _cityIdForSelectedPoint();
    _attachChangeListeners();
    _registerFormController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _questionOneController.dispose();
    _questionTwoController.dispose();
    _questionThreeController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    _unregisterFormController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointIdsForSelectedCity = _pointIdsForSelectedCity();

    final availablePoints = widget.availablePoints
        .where((point) => point.id != null)
        .where(
          (point) =>
              pointIdsForSelectedCity.contains(
                TextNormalizer.toAsciiSlug(point.id!),
              ) ||
              _belongsToSelectedCity(point),
        )
        .toList();

    return CustomCard(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cada punto de interés solo puede tener una misión asociada.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _buildLabel('Título de la Misión'),
              SizedBox(width: 420, child: _buildTextField(_titleController)),
              const SizedBox(height: 24),
              _buildLabel('Ciudad'),
              const SizedBox(height: 8),
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<String>(
                  initialValue:
                      widget.cities.any((city) => city.id == _selectedCityId)
                      ? _selectedCityId
                      : null,
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: widget.cities
                      .where((city) => city.id != null)
                      .map(
                        (city) => DropdownMenuItem<String>(
                          value: city.id!,
                          child: Text(
                            city.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCityId = value;
                      _selectedPointId = null;
                    });
                    widget.formController.markChanged();
                  },
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Punto de interés'),
              const SizedBox(height: 8),
              SizedBox(
                width: 420,
                child: DropdownButtonFormField<String>(
                  initialValue:
                      availablePoints.any((p) => p.id == _selectedPointId)
                      ? _selectedPointId
                      : null,
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: availablePoints
                      .map(
                        (point) => DropdownMenuItem<String>(
                          value: point.id!,
                          child: Text(
                            '${point.name} (${_cityNameForPoint(point)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _selectedCityId == null || availablePoints.isEmpty
                      ? null
                      : (value) {
                          setState(() => _selectedPointId = value);
                          widget.formController.markChanged();
                        },
                ),
              ),
              const SizedBox(height: 30),

              // Question accordion
              _buildQuestionAccordion(
                number: 1,
                questionController: _questionOneController,
                answersOffset: 0,
              ),
              const SizedBox(height: 12),
              _buildQuestionAccordion(
                number: 2,
                questionController: _questionTwoController,
                answersOffset: 3,
              ),
              const SizedBox(height: 12),
              _buildQuestionAccordion(
                number: 3,
                questionController: _questionThreeController,
                answersOffset: 6,
              ),

            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionAccordion({
    required int number,
    required TextEditingController questionController,
    required int answersOffset,
  }) {
    return SizedBox(
      width: 520,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF6B7249).withValues(alpha: 0.5),
          ),
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            'Configurar Pregunta $number',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7249),
            ),
          ),
          childrenPadding: const EdgeInsets.all(12),
          children: [
            _buildLabel('Enunciado de la pregunta'),
            const SizedBox(height: 8),
            SizedBox(width: 460, child: _buildTextField(questionController)),
            const SizedBox(height: 16),
            for (var i = 0; i < 3; i++) ...[
              _buildLabel('Respuesta ${i + 1}'),
              const SizedBox(height: 8),
              SizedBox(
                width: 460,
                child: _buildTextField(_answerControllers[answersOffset + i]),
              ),
              const SizedBox(height: 12),
            ],
            _buildLabel('¿Cuál es la correcta?'),
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<int>(
                initialValue: _correctAnswers[number - 1],
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Respuesta 1')),
                  DropdownMenuItem(value: 1, child: Text('Respuesta 2')),
                  DropdownMenuItem(value: 2, child: Text('Respuesta 3')),
                ],
                onChanged: (value) {
                  setState(() => _correctAnswers[number - 1] = value ?? 0);
                  widget.formController.markChanged();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AdminMissionQuestion> _buildQuestions() {
    final questionControllers = [
      _questionOneController,
      _questionTwoController,
      _questionThreeController,
    ];
    return List<AdminMissionQuestion>.generate(3, (index) {
      final offset = index * 3;
      return AdminMissionQuestion(
        text: questionControllers[index].text.trim(),
        answers: [
          _answerControllers[offset].text.trim(),
          _answerControllers[offset + 1].text.trim(),
          _answerControllers[offset + 2].text.trim(),
        ],
        correctIndex: _correctAnswers[index],
      );
    });
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(controller: controller, decoration: _inputDecoration());
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F1E6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6B7249)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6B7249)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  String? _validate(Set<String> usedPointIds) {
    if (_titleController.text.trim().isEmpty) {
      return 'Introduce el título de la misión';
    }
    if (_selectedCityId == null || _selectedCityId!.isEmpty) {
      return 'Selecciona una ciudad';
    }
    if (_selectedPointId == null || _selectedPointId!.isEmpty) {
      return 'Selecciona un punto';
    }
    final questions = [
      _questionOneController.text.trim(),
      _questionTwoController.text.trim(),
      _questionThreeController.text.trim(),
    ];
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].isEmpty) return 'La pregunta ${i + 1} está vacía';
    }

    for (var i = 0; i < _answerControllers.length; i++) {
      if (_answerControllers[i].text.trim().isEmpty) {
        return 'Faltan respuestas por completar';
      }
    }
    return null;
  }

  String _cityNameFor(String cityId) {
    for (final city in widget.cities) {
      if (_belongsToCity(cityId, city)) {
        return city.name;
      }
    }

    return 'Desconocida';
  }

  String _cityNameForPoint(AdminPoiModel point) {
    final directCityName = _cityNameFor(point.cityId);
    if (directCityName != 'Desconocida') return directCityName;

    final selectedCityId = _selectedCityId;
    final pointId = point.id;
    if (selectedCityId == null || pointId == null) return directCityName;

    final pointIdsForSelectedCity = _pointIdsForSelectedCity();
    if (!pointIdsForSelectedCity.contains(
      TextNormalizer.toAsciiSlug(pointId),
    )) {
      return directCityName;
    }

    for (final city in widget.cities) {
      if (city.id == selectedCityId) return city.name;
    }

    return directCityName;
  }

  String? _cityIdForSelectedPoint() {
    final selectedPointId = _selectedPointId;
    if (selectedPointId == null || selectedPointId.isEmpty) return null;

    for (final point in widget.availablePoints) {
      if (point.id == selectedPointId) {
        for (final city in widget.cities) {
          if (_pointBelongsToCity(point, city)) return city.id;
        }
      }
    }

    return null;
  }

  bool _belongsToSelectedCity(AdminPoiModel point) {
    final selectedCityId = _selectedCityId;
    if (selectedCityId == null || selectedCityId.isEmpty) return false;

    for (final city in widget.cities) {
      if (city.id == selectedCityId) {
        return _pointBelongsToCity(point, city);
      }
    }

    return false;
  }

  bool _pointBelongsToCity(AdminPoiModel point, AdminCityModel city) {
    if (_belongsToCity(point.cityId, city)) return true;

    final pointId = point.id;
    if (pointId == null || pointId.isEmpty) return false;

    final normalizedPointId = TextNormalizer.toAsciiSlug(pointId);
    for (final route in widget.routes) {
      if (!_belongsToCity(route.cityId, city)) continue;

      final routePointIds = route.pointIds.map(TextNormalizer.toAsciiSlug);
      if (routePointIds.contains(normalizedPointId)) return true;
    }

    return false;
  }

  Set<String> _pointIdsForSelectedCity() {
    final selectedCityId = _selectedCityId;
    if (selectedCityId == null || selectedCityId.isEmpty) return {};

    AdminCityModel? selectedCity;
    for (final city in widget.cities) {
      if (city.id == selectedCityId) {
        selectedCity = city;
        break;
      }
    }

    if (selectedCity == null) return {};

    return widget.routes
        .where((route) => _belongsToCity(route.cityId, selectedCity!))
        .expand((route) => route.pointIds)
        .map(TextNormalizer.toAsciiSlug)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  bool _belongsToCity(String rawCityValue, AdminCityModel city) {
    final normalizedValue = TextNormalizer.toAsciiSlug(rawCityValue);
    final cityId = TextNormalizer.toAsciiSlug(city.id ?? '');
    final cityName = TextNormalizer.toAsciiSlug(city.name);

    return normalizedValue.isNotEmpty &&
        (normalizedValue == cityId || normalizedValue == cityName);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _attachChangeListeners() {
    _titleController.addListener(_markChanged);
    _questionOneController.addListener(_markChanged);
    _questionTwoController.addListener(_markChanged);
    _questionThreeController.addListener(_markChanged);
    for (final controller in _answerControllers) {
      controller.addListener(_markChanged);
    }
  }

  void _markChanged() {
    widget.formController.markChanged();
  }

  void _registerFormController() {
    _unregisterFormController();
    _formControllerToken = widget.formController.registerSaveAction(() async {
      final usedPointIds = widget.existingMissions
          .where((mission) => mission.id != widget.mission?.id)
          .map((mission) => mission.pointId)
          .where((id) => id.isNotEmpty)
          .map(TextNormalizer.toAsciiSlug)
          .toSet();

      _save(usedPointIds);
    });
  }

  void _unregisterFormController() {
    final token = _formControllerToken;
    if (token == null) return;

    widget.formController.unregisterSaveAction(token);
    _formControllerToken = null;
  }

  void _save(Set<String> usedPointIds) {
    final error = _validate(usedPointIds);
    if (error != null) {
      _showMessage(error);
      return;
    }

    widget.onSave(
      AdminMissionModel(
        id: widget.mission?.id,
        pointId: _selectedPointId ?? '',
        title: _titleController.text.trim(),
        questions: _buildQuestions(),
      ),
    );
  }
}
