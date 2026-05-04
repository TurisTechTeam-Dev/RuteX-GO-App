/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../constants/app_colors.dart';

class AudioGuideWidget extends StatefulWidget {
  final String text;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool autoRead;
  final Duration autoReadDelay;
  final Object heroTag;
  final String? semanticLabel;

  const AudioGuideWidget({
    super.key,
    required this.text,
    this.iconSize = 30,
    this.iconColor,
    this.backgroundColor,
    this.autoRead = false,
    this.autoReadDelay = const Duration(milliseconds: 2200),
    this.heroTag = 'fab_audioguia',
    this.semanticLabel,
  });

  @override
  State<AudioGuideWidget> createState() => _AudioGuideWidgetState();
}

class _AudioGuideWidgetState extends State<AudioGuideWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _autoReadTimer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _flutterTts.setCompletionHandler(_markStopped);
    _flutterTts.setCancelHandler(_markStopped);
    _flutterTts.setErrorHandler((message) => _markStopped());

    _scheduleAutoRead();
  }

  @override
  void didUpdateWidget(covariant AudioGuideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldReschedule =
        widget.autoRead &&
        (widget.text != oldWidget.text ||
            widget.autoRead != oldWidget.autoRead ||
            widget.autoReadDelay != oldWidget.autoReadDelay);

    if (shouldReschedule) {
      _scheduleAutoRead();
    } else if (!widget.autoRead) {
      _cancelAutoRead();
    }
  }

  void _scheduleAutoRead() {
    _cancelAutoRead();

    if (!widget.autoRead || widget.text.trim().isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.autoRead || widget.text.trim().isEmpty) return;

      _autoReadTimer = Timer(widget.autoReadDelay, () {
        if (!mounted || !widget.autoRead) return;
        _speak();
      });
    });
  }

  void _cancelAutoRead() {
    _autoReadTimer?.cancel();
    _autoReadTimer = null;
  }

  Future<void> _speak() async {
    _cancelAutoRead();

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
    _cancelAutoRead();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = _isPlaying ? 'Detener audioguía' : 'Reproducir audioguía';

    return Semantics(
      label: widget.semanticLabel ?? action,
      button: true,
      enabled: widget.text.trim().isNotEmpty,
      child: FloatingActionButton(
        heroTag: widget.heroTag,
        tooltip: action,
        backgroundColor: widget.backgroundColor ?? AppColors.verdePrincipal,
        foregroundColor: widget.iconColor ?? AppColors.blancoPuro,
        elevation: 6,
        onPressed: _isPlaying ? _stop : _speak,
        child: Icon(
          _isPlaying ? Icons.stop : Icons.volume_up,
          size: widget.iconSize,
        ),
      ),
    );
  }
}
