import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:mobile_app/core/widgets/buttons/custom_button.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';
import 'package:mobile_app/core/utils/text_normalizer.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/image_picker_box.dart';

class CityForm extends StatefulWidget {
  final AdminCityModel? city;
  final ValueChanged<AdminCityModel> onSave;
  final VoidCallback onCancel;
  final Future<String> Function(Uint8List bytes, String fileName) onUploadImage;

  const CityForm({
    super.key,
    this.city,
    required this.onSave,
    required this.onCancel,
    required this.onUploadImage,
  });

  @override
  State<CityForm> createState() => _CityFormState();
}

class _CityFormState extends State<CityForm> {
  final ScrollController _scrollController = ScrollController();

  late final TextEditingController _nameController;
  late final TextEditingController _provinceController;
  late final TextEditingController _imageController;
  bool isActive = false;
  bool _isUploading = false;
  Uint8List? _pendingImageBytes;
  String? _pendingImageName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.city?.name);
    _provinceController = TextEditingController(text: widget.city?.province);
    _imageController = TextEditingController(text: widget.city?.imageUrl);
    isActive = widget.city?.isActive ?? false;
  }

  @override
  void didUpdateWidget(covariant CityForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city?.id != widget.city?.id ||
        oldWidget.city?.imageUrl != widget.city?.imageUrl ||
        oldWidget.city?.name != widget.city?.name) {
      _nameController.text = widget.city?.name ?? '';
      _provinceController.text = widget.city?.province ?? '';
      _imageController.text = widget.city?.imageUrl ?? '';
      _pendingImageBytes = null;
      _pendingImageName = null;
      setState(() {
        isActive = widget.city?.isActive ?? false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _provinceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                  ),
                  const Text(
                    'Editar Ciudad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nombre de la Ciudad'),
                        _buildTextField(_nameController),
                        const SizedBox(height: 16),

                        _buildLabel('Provincia (Capital)'),
                        _buildTextField(_provinceController),
                        const SizedBox(height: 12),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            '¿Ciudad activa en la app?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value: isActive,
                          activeThumbColor: const Color(0xFF6B7249),
                          onChanged: (val) => setState(() => isActive = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Imagen de la Ciudad'),
                        const SizedBox(height: 8),
                        ImagePickerBox(
                          imageUrl: _imageController.text,
                          alternateImageSources: [
                            if (widget.city?.id != null)
                              'assets/images_selection/${widget.city!.id}.jpg',
                            'assets/images_selection/${TextNormalizer.toAsciiSlug(_nameController.text)}.jpg',
                            _nameController.text,
                            if (widget.city != null) widget.city!.name,
                          ],
                          isUploading: _isUploading,
                          onImageSelected: (bytes, name) {
                            setState(() {
                              _pendingImageBytes = bytes;
                              _pendingImageName = name;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),
              Center(
                child: SizedBox(
                  width: 220,
                  child: CustomButton(
                    text: _isUploading ? 'SUBIENDO...' : 'GUARDAR CAMBIOS',
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (_nameController.text.trim().isEmpty ||
                                _provinceController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, rellena los campos obligatorios (Nombre y Provincia)',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final imageUrl = await _uploadPendingImage();
                            if (imageUrl == null) return;
                            widget.onSave(
                              AdminCityModel(
                                id: widget.city?.id,
                                name: _nameController.text.trim(),
                                province: _provinceController.text.trim(),
                                imageUrl: imageUrl,
                                isActive: isActive,
                              ),
                            );
                          },
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6B7249)),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
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
