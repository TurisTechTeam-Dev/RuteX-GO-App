import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:mobile_app/core/widgets/buttons/custom_button.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/image_picker_box.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';

class PointInterestForm extends StatefulWidget {
  const PointInterestForm({
    super.key,
    this.point,
    required this.cities,
    required this.onSave,
    required this.onUploadImage,
  });

  final AdminPoiModel? point;
  final List<AdminCityModel> cities;
  final ValueChanged<AdminPoiModel> onSave;
  final Future<String> Function(Uint8List bytes, String fileName) onUploadImage;

  @override
  State<PointInterestForm> createState() => _PointInterestFormState();
}

class _PointInterestFormState extends State<PointInterestForm> {
  static const LatLng _meridaCentro = LatLng(38.9161, -6.3437);

  final ScrollController _scrollController = ScrollController();

  late final TextEditingController _nameController;
  late final TextEditingController _imageController;
  late final TextEditingController _qrController;
  late final TextEditingController _activationRadiusController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final MapController _mapController;
  late String? _selectedCityId;
  bool _isUploading = false;
  Uint8List? _pendingImageBytes;
  String? _pendingImageName;

  LatLng? _selectedCoordinates;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.point?.name);
    _imageController = TextEditingController(text: widget.point?.imageUrl);
    _qrController = TextEditingController(text: widget.point?.qrCode);
    _activationRadiusController = TextEditingController(
      text: (widget.point?.activationRadius ?? 20).toString(),
    );
    _latitudeController = TextEditingController(
      text: widget.point?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.point?.longitude?.toString() ?? '',
    );
    _selectedCityId = widget.point?.cityId;
    // Keep dropdown values valid after data refresh.
    if (_selectedCityId != null &&
        (_selectedCityId!.isEmpty ||
            !widget.cities.any((c) => c.id == _selectedCityId))) {
      _selectedCityId = null;
    }
    _mapController = MapController();

    if (widget.point?.latitude != null && widget.point?.longitude != null) {
      _selectedCoordinates = LatLng(
        widget.point!.latitude!,
        widget.point!.longitude!,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveMapToSelection();
    });
  }

  @override
  void didUpdateWidget(covariant PointInterestForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pointChanged =
        oldWidget.point?.id != widget.point?.id ||
        oldWidget.point?.latitude != widget.point?.latitude ||
        oldWidget.point?.longitude != widget.point?.longitude ||
        oldWidget.point?.imageUrl != widget.point?.imageUrl ||
        oldWidget.point?.name != widget.point?.name ||
        oldWidget.point?.qrCode != widget.point?.qrCode ||
        oldWidget.point?.cityId != widget.point?.cityId;

    if (!pointChanged) return;

    _nameController.text = widget.point?.name ?? '';
    _imageController.text = widget.point?.imageUrl ?? '';
    _pendingImageBytes = null;
    _pendingImageName = null;
    _qrController.text = widget.point?.qrCode ?? '';
    _activationRadiusController.text = (widget.point?.activationRadius ?? 20)
        .toString();
    _latitudeController.text = widget.point?.latitude?.toString() ?? '';
    _longitudeController.text = widget.point?.longitude?.toString() ?? '';
    _selectedCityId = widget.point?.cityId;

    // Keep dropdown values valid after data refresh.
    if (_selectedCityId != null &&
        (_selectedCityId!.isEmpty ||
            !widget.cities.any((c) => c.id == _selectedCityId))) {
      _selectedCityId = null;
    }

    if (widget.point?.latitude != null && widget.point?.longitude != null) {
      _selectedCoordinates = LatLng(
        widget.point!.latitude!,
        widget.point!.longitude!,
      );
    } else {
      _selectedCoordinates = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveMapToSelection();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _imageController.dispose();
    _qrController.dispose();
    _activationRadiusController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _selectedCoordinates ?? _meridaCentro;

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
              Row(
                children: [
                  SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nombre'),
                        _buildTextField(_nameController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Código QR'),
                        _buildTextField(_qrController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: 520,
                child: ImagePickerBox(
                  imageUrl: _imageController.text,
                  alternateImageSources: [
                    _qrController.text,
                    _nameController.text,
                    if (widget.point != null) widget.point!.qrCode,
                    if (widget.point != null) widget.point!.name,
                  ],
                  isUploading: _isUploading,
                  onImageSelected: (bytes, name) {
                    setState(() {
                      _pendingImageBytes = bytes;
                      _pendingImageName = name;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  SizedBox(
                    width: 340,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Ciudad'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCityId,
                          decoration: _inputDecoration(),
                          items: widget.cities
                              .where((c) => c.id != null)
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCityId = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Radio de activación'),
                        _buildTextField(_activationRadiusController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Selecciona coordenadas en el mapa'),
              const SizedBox(height: 6),
              const Text(
                'Haz clic sobre el mapa para capturar latitud y longitud. Usa + y - para ajustar el zoom.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              // Keep the map centered while editing coordinates
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      FlutterMap(
                        key: ValueKey(
                          '${widget.point?.id ?? 'nuevo'}-${_selectedCoordinates?.latitude}-${_selectedCoordinates?.longitude}',
                        ),
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: mapCenter,
                          initialZoom: _selectedCoordinates == null ? 13 : 16,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.all &
                                ~InteractiveFlag.scrollWheelZoom,
                          ),
                          onTap: (tapPosition, latLng) =>
                              _setCoordinates(latLng),
                          onSecondaryTap: (tapPosition, latLng) =>
                              _setCoordinates(latLng),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.rutexgo.mobile_app',
                          ),
                          if (_selectedCoordinates != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedCoordinates!,
                                  width: 44,
                                  height: 44,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          children: [
                            _MapZoomButton(
                              icon: Icons.add,
                              onPressed: () => _zoomMap(1),
                            ),
                            const SizedBox(height: 6),
                            _MapZoomButton(
                              icon: Icons.remove,
                              onPressed: () => _zoomMap(-1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _selectedCoordinates == null
                    ? null
                    : () {
                        setState(() {
                          _selectedCoordinates = null;
                          _latitudeController.clear();
                          _longitudeController.clear();
                        });
                        _moveMapToSelection();
                      },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar coordenadas'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Latitud'),
                        _buildTextField(
                          _latitudeController,
                          onChanged: (_) => _syncCoordinatesFromInputs(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Longitud'),
                        _buildTextField(
                          _longitudeController,
                          onChanged: (_) => _syncCoordinatesFromInputs(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: CustomButton(
                      text: _isUploading ? 'SUBIENDO...' : 'GUARDAR PUNTO',
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final error = _validate();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              final imageUrl = await _uploadPendingImage();
                              if (imageUrl == null) return;

                              widget.onSave(
                                AdminPoiModel(
                                  id: widget.point?.id,
                                  name: _nameController.text.trim(),
                                  description: '',
                                  imageUrl: imageUrl,
                                  qrCode: _qrController.text.trim(),
                                  activationRadius:
                                      int.tryParse(
                                        _activationRadiusController.text.trim(),
                                      ) ??
                                      20,
                                  cityId: _selectedCityId ?? '',
                                  latitude: _selectedCoordinates?.latitude,
                                  longitude: _selectedCoordinates?.longitude,
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
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

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'El nombre es obligatorio';
    if (_selectedCityId == null) return 'Selecciona una ciudad';
    if (_latitudeController.text.trim().isEmpty ||
        _longitudeController.text.trim().isEmpty) {
      return 'Las coordenadas son obligatorias';
    }
    if (double.tryParse(_latitudeController.text.trim()) == null ||
        double.tryParse(_longitudeController.text.trim()) == null) {
      return 'Las coordenadas deben ser números válidos';
    }
    return null;
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6B7249)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void _setCoordinates(LatLng latLng) {
    setState(() {
      _selectedCoordinates = latLng;
      _latitudeController.text = latLng.latitude.toStringAsFixed(6);
      _longitudeController.text = latLng.longitude.toStringAsFixed(6);
    });
    _moveMapToSelection();
  }

  void _syncCoordinatesFromInputs() {
    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());

    if (lat == null || lng == null) return;

    setState(() {
      _selectedCoordinates = LatLng(lat, lng);
    });
    _moveMapToSelection();
  }

  void _moveMapToSelection() {
    if (!mounted) return;
    final target = _selectedCoordinates ?? _meridaCentro;
    _mapController.move(target, _selectedCoordinates == null ? 13 : 16);
  }

  void _zoomMap(double zoomDelta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + zoomDelta);
  }

  Future<String?> _uploadPendingImage() async {
    final bytes = _pendingImageBytes;
    final name = _pendingImageName;
    if (bytes == null || name == null) return _imageController.text.trim();

    setState(() => _isUploading = true);
    try {
      final imageUrl = await widget.onUploadImage(bytes, name);
      if (!mounted) return null;

      _imageController.text = imageUrl;
      _pendingImageBytes = null;
      _pendingImageName = null;
      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al subir: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}

class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: const Color(0xFF6B7249)),
        ),
      ),
    );
  }
}
