import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:mobile_app/core/widgets/images/storage_aware_image.dart';

class ImagePickerBox extends StatefulWidget {
  final String? imageUrl;
  final List<String> alternateImageSources;
  final bool isUploading;
  final void Function(Uint8List bytes, String fileName) onImageSelected;
  final String label;

  const ImagePickerBox({
    super.key,
    this.imageUrl,
    this.alternateImageSources = const [],
    this.isUploading = false,
    required this.onImageSelected,
    this.label = 'Añadir Imagen',
  });

  @override
  State<ImagePickerBox> createState() => _ImagePickerBoxState();
}

class _ImagePickerBoxState extends State<ImagePickerBox> {
  Uint8List? _localBytes;

  @override
  void didUpdateWidget(covariant ImagePickerBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedRecordImage = oldWidget.imageUrl != widget.imageUrl;
    final uploadJustFinished = oldWidget.isUploading && !widget.isUploading;

    if (changedRecordImage && !uploadJustFinished) {
      _localBytes = null;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _localBytes = bytes;
      });
      widget.onImageSelected(bytes, image.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRemoteSource =
        (widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty) ||
        widget.alternateImageSources.any((source) => source.trim().isNotEmpty);
    final hasImage =
        hasRemoteSource || _localBytes != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isUploading ? null : _pickImage,
        child: Container(
          height: 132,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F1E6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF6B7249).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                if (hasImage)
                  Positioned.fill(
                    child: _localBytes != null
                        ? Image.memory(_localBytes!, fit: BoxFit.cover)
                        : StorageAwareImage(
                            source: widget.imageUrl,
                            alternateSources: widget.alternateImageSources,
                            fit: BoxFit.cover,
                            placeholder: const _ImageLoadingState(),
                            fallback: const _ImageFallback(),
                          ),
                  ),

                if (hasImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (!hasImage && !widget.isUploading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6B7249,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 24,
                            color: Color(0xFF6B7249),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Color(0xFF6B7249),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Click para seleccionar',
                          style: TextStyle(
                            color: const Color(
                              0xFF6B7249,
                            ).withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.isUploading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Subiendo imagen...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (hasImage && !widget.isUploading)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFF6B7249),
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
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Sin vista previa',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ImageLoadingState extends StatelessWidget {
  const _ImageLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.6,
          color: Color(0xFF6B7249),
        ),
      ),
    );
  }
}
