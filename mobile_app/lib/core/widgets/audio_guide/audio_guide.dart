import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../constants/app_colors.dart';

class AudioGuideWidget extends StatefulWidget {
  final String text;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool autoRead;
  final Object heroTag;

  const AudioGuideWidget({
    super.key,
    required this.text,
    this.iconSize = 30,
    this.iconColor,
    this.backgroundColor,
    this.autoRead = false,
    this.heroTag = 'fab_audioguia',
  });

  @override
  State<AudioGuideWidget> createState() => _AudioGuideWidgetState();
}

class _AudioGuideWidgetState extends State<AudioGuideWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _flutterTts.setCompletionHandler(_markStopped);
    _flutterTts.setCancelHandler(_markStopped);
    _flutterTts.setErrorHandler((message) => _markStopped());

    if (widget.autoRead && widget.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    }
  }

  @override
  void didUpdateWidget(covariant AudioGuideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoRead &&
        widget.text != oldWidget.text &&
        widget.text.trim().isNotEmpty) {
      _speak();
    }
  }

  Future<void> _speak() async {
    final text = widget.text.trim();
    if (text.isEmpty) return;

    await _flutterTts.stop();
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setPitch(1);
    await _flutterTts.speak(text);

    if (mounted) {
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    _markStopped();
  }

  void _markStopped() {
    if (!mounted) return;
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: widget.heroTag,
      backgroundColor: widget.backgroundColor ?? AppColors.verdePrincipal,
      foregroundColor: widget.iconColor ?? AppColors.blancoPuro,
      elevation: 6,
      onPressed: _isPlaying ? _stop : _speak,
      child: Icon(
        _isPlaying ? Icons.stop : Icons.volume_up,
        size: widget.iconSize,
      ),
    );
  }
}
