/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/text_normalizer.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_form_controller.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/image_picker_box.dart';

class RouteForm extends StatefulWidget {
  const RouteForm({
    super.key,
    this.route,
    required this.availableCities,
    required this.availablePoints,
    required this.availableMissions,
    required this.formController,
    required this.onSave,
    required this.onUploadImage,
  });

  final AdminRouteModel? route;
  final List<AdminCityModel> availableCities;
  final List<AdminPoiModel> availablePoints;
  final List<AdminMissionModel> availableMissions;
  final AdminFormController formController;
  final Future<void> Function(AdminRouteModel) onSave;
  final Future<String> Function(Uint8List bytes, String fileName) onUploadImage;

  @override
  State<RouteForm> createState() => _RouteFormState();
}

class _RouteFormState extends State<RouteForm> {
  static const double _singleLineFieldHeight = 60;
  static const EdgeInsets _fieldContentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 14,
  );

  final ScrollController _scrollController = ScrollController();

  late final TextEditingController _nameController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _durationController;
  late final TextEditingController _totalPointsController;
  late final TextEditingController _imageController;

  late String? _selectedCity;
  late List<String> _selectedPointIds;
  late bool _isActive;
  bool _isUploading = false;
  Uint8List? _pendingImageBytes;
  String? _pendingImageName;
  Object? _formControllerToken;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.route?.name);
    _difficultyController = TextEditingController(
      text: widget.route?.difficulty,
    );
    _durationController = TextEditingController(text: widget.route?.duration);
    _totalPointsController = TextEditingController(
      text: widget.route?.totalPoints.toString() ?? '',
    );
    _imageController = TextEditingController(text: widget.route?.image);
    _selectedCity = widget.route?.cityId;
    _selectedPointIds = List<String>.from(widget.route?.pointIds ?? []);
    _isActive = widget.route?.isActive ?? false;
    _attachChangeListeners();
    _registerFormController();
  }

  @override
  void didUpdateWidget(covariant RouteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route?.id != widget.route?.id ||
        oldWidget.route?.image != widget.route?.image) {
      _nameController.text = widget.route?.name ?? '';
      _difficultyController.text = widget.route?.difficulty ?? '';
      _durationController.text = widget.route?.duration ?? '';
      _totalPointsController.text = widget.route?.totalPoints.toString() ?? '';
      _imageController.text = widget.route?.image ?? '';
      _pendingImageBytes = null;
      _pendingImageName = null;
      setState(() {
        _selectedCity = widget.route?.cityId;
        _selectedPointIds = List<String>.from(widget.route?.pointIds ?? []);
        _isActive = widget.route?.isActive ?? false;
      });
      widget.formController.markClean();
      _registerFormController();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _difficultyController.dispose();
    _durationController.dispose();
    _totalPointsController.dispose();
    _imageController.dispose();
    _unregisterFormController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;
          final primaryWidth = isNarrow ? double.infinity : 380.0;
          final secondaryWidth = isNarrow ? double.infinity : 300.0;

          return Scrollbar(
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
                    Flex(
                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: primaryWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Nombre'),
                              _buildTextField(_nameController),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Dificultad'),
                                        _buildTextField(_difficultyController),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Duración'),
                                        _buildTextField(_durationController),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Puntos totales'),
                              _buildTextField(_totalPointsController),
                              const SizedBox(height: 16),
                              _buildLabel('Imagen de la Ruta'),
                              const SizedBox(height: 8),
                              ImagePickerBox(
                                imageUrl: _imageController.text,
                                alternateImageSources: [
                                  if (widget.route != null) ...[
                                    _nameController.text,
                                    widget.route!.name,
                                  ],
                                ],
                                isUploading: _isUploading,
                                onImageSelected: (bytes, name) {
                                  setState(() {
                                    _pendingImageBytes = bytes;
                                    _pendingImageName = name;
                                  });
                                  widget.formController.markChanged();
                                },
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: const Text(
                                  '¿Ruta activa?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: _isActive,
                                activeThumbColor: Color(0xFF6B7249),
                                onChanged: (val) {
                                  setState(() => _isActive = val);
                                  widget.formController.markChanged();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isNarrow ? 0 : 16, height: 16),
                        SizedBox(
                          width: secondaryWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Ciudad'),
                              SizedBox(
                                height: _singleLineFieldHeight,
                                child: DropdownButtonFormField<String>(
                                  initialValue:
                                  widget.availableCities.any(
                                        (c) => c.id == _selectedCity,
                                  )
                                      ? _selectedCity
                                      : null,
                                  isExpanded: true,
                                  decoration: _inputDecoration(),
                                  items: widget.availableCities
                                      .where((city) => city.id != null)
                                      .map(
                                        (city) => DropdownMenuItem<String>(
                                      value: city.id!,
                                      child: Text(city.name),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedCity = value);
                                    widget.formController.markChanged();
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Puntos de Interés'),
                              const SizedBox(height: 8),
                              Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF6B7249,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: _selectedCity == null
                                    ? const Center(
                                  child: Text(
                                    'Selecciona una ciudad primero',
                                  ),
                                )
                                    : _filteredPoints().isEmpty
                                    ? const Center(
                                  child: Text(
                                    'No hay puntos en esta ciudad',
                                  ),
                                )
                                    : ListView.builder(
                                  itemCount: _filteredPoints().length,
                                  itemBuilder: (context, index) {
                                    final poi = _filteredPoints()[index];
                                    final isSelected = _selectedPointIds
                                        .contains(poi.id);
                                    return CheckboxListTile(
                                      secondary: const Icon(
                                        Icons.location_on,
                                        color: Colors.redAccent,
                                      ),
                                      title: Text(
                                        poi.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        poi.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      value: isSelected,
                                      activeColor: const Color(
                                        0xFF6B7249,
                                      ),
                                      onChanged: (checked) {
                                        setState(() {
                                          if (checked == true) {
                                            if (poi.id != null) {
                                              _selectedPointIds.add(
                                                poi.id!,
                                              );
                                            }
                                          } else {
                                            _selectedPointIds.remove(
                                              poi.id,
                                            );
                                          }
                                        });
                                        widget.formController.markChanged();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<AdminPoiModel> _filteredPoints() {
    if (_selectedCity == null || _selectedCity!.isEmpty) return [];

    final selectedCity = widget.availableCities.firstWhere(
          (c) => c.id == _selectedCity || c.name == _selectedCity,
      orElse: () => const AdminCityModel(
        id: '',
        name: '',
        province: '',
        imageUrl: '',
        isActive: false,
      ),
    );

    return widget.availablePoints.where((poi) {
      if (poi.id != null && _selectedPointIds.contains(poi.id)) return true;
      return _belongsToCity(poi.cityId, selectedCity);
    }).toList();
  }

  bool _belongsToCity(String rawCityValue, AdminCityModel city) {
    final normalizedValue = TextNormalizer.toAsciiSlug(rawCityValue);
    final cityId = TextNormalizer.toAsciiSlug(city.id ?? '');
    final cityName = TextNormalizer.toAsciiSlug(city.name);

    return normalizedValue.isNotEmpty &&
        (normalizedValue == cityId || normalizedValue == cityName);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    final textField = TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => _markChanged(),
      textAlignVertical: maxLines == 1 ? TextAlignVertical.center : null,
      decoration: _inputDecoration(),
    );

    if (maxLines > 1) return textField;

    return SizedBox(height: _singleLineFieldHeight, child: textField);
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
      isDense: true,
      contentPadding: _fieldContentPadding,
    );
  }

  String? _validate(Set<String> puntosConMision) {
    if (_nameController.text.trim().isEmpty) {
      return 'Introduce el nombre de la ruta';
    }
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      return 'Selecciona una ciudad';
    }
    if (_selectedPointIds.isEmpty) {
      return 'Añade al menos un punto de interés';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _uploadPendingImage() async {
    final bytes = _pendingImageBytes;
    final name = _pendingImageName;
    if (bytes == null || name == null) return _imageController.text.trim();

    setState(() => _isUploading = true);
    try {
      final imagePath = await widget.onUploadImage(bytes, name);
      if (!mounted) return null;

      _imageController.text = imagePath;
      _pendingImageBytes = null;
      _pendingImageName = null;
      return imagePath;
    } catch (e) {
      if (mounted) _showMessage("Error al subir: $e");
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _attachChangeListeners() {
    _nameController.addListener(_markChanged);
    _difficultyController.addListener(_markChanged);
    _durationController.addListener(_markChanged);
    _totalPointsController.addListener(_markChanged);
    _imageController.addListener(_markChanged);
  }

  void _markChanged() {
    widget.formController.markChanged();
  }

  void _registerFormController() {
    _unregisterFormController();
    _formControllerToken = widget.formController.registerSaveAction(_save);
  }

  void _unregisterFormController() {
    final token = _formControllerToken;
    if (token == null) return;

    widget.formController.unregisterSaveAction(token);
    _formControllerToken = null;
  }

  Future<void> _save() async {
    if (_isUploading) return;
    final error = _validate(_filteredPoints().map((p) => p.id!).toSet());
    if (error != null) {
      _showMessage(error);
      return;
    }
    final imagePath = await _uploadPendingImage();
    if (imagePath == null) return;

    await widget.onSave(
      AdminRouteModel(
        id: widget.route?.id,
        name: _nameController.text.trim(),
        difficulty: _difficultyController.text.trim(),
        duration: _durationController.text.trim(),
        cityId: _selectedCity ?? '',
        pointIds: _selectedPointIds.toSet().toList(),
        image: imagePath,
        isActive: _isActive,
        totalPoints: int.tryParse(_totalPointsController.text.trim()) ?? 0,
      ),
    );
  }
}