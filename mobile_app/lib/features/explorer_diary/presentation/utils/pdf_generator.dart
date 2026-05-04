/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripcion: Esta aplicacion y su codigo fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribucion o uso no autorizado.
  Anio: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/diary_entry.dart';

class PdfGenerator {
  static const int _maxPhotosPerRoute = 4;
  static final PdfPageFormat _pageFormat = PdfPageFormat.a4.landscape;

  static Future<void> generateExplorerBook({
    required flutter.BuildContext context,
    required List<DiaryEntry> allRoutes,
    required String userName,
  }) async {
    final pdf = pw.Document();
    final logoImage = await _loadImage('assets/Logo_Color_Rutexgo.png');
    final sealImage = await _loadImage('assets/Sello_ruta_monumental_romana.png');
    final extremaduraImage = await _loadImage(
      'assets/Mapa_fondo_Extremadura.png',
    );

    try {
      pdf.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) => _buildCover(
            logoImage: logoImage,
            userName: userName,
          ),
        ),
      );

      for (final entry in allRoutes) {
        pdf.addPage(
          pw.Page(
            pageFormat: _pageFormat,
            margin: pw.EdgeInsets.zero,
            build: (context) => _buildRoutePage(
              entry: entry,
              logoImage: logoImage,
              extremaduraImage: extremaduraImage,
              sealImage: sealImage,
            ),
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) => _buildFinalPage(logoImage),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'diario_explorador_rutexgo.pdf',
        format: _pageFormat,
        dynamicLayout: false,
      );
    } catch (error) {
      flutter.debugPrint('Error PDF: $error');
    }
  }

  static Future<pw.MemoryImage> _loadImage(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  static pw.Widget _buildCover({
    required pw.MemoryImage logoImage,
    required String userName,
  }) {
    return _page(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Image(logoImage, height: 138),
          pw.SizedBox(height: 34),
          pw.Text(
            'MI DIARIO DEL EXPLORADOR',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 31, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 18),
          pw.Container(width: 280, height: 1.5, color: PdfColors.grey700),
          pw.SizedBox(height: 18),
          pw.Text(
            userName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 32),
          pw.Text(
            'Extremadura en tus manos',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 15,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRoutePage({
    required DiaryEntry entry,
    required pw.MemoryImage logoImage,
    required pw.MemoryImage extremaduraImage,
    required pw.MemoryImage sealImage,
  }) {
    return _page(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            children: [
              pw.Image(extremaduraImage, height: 38),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  'DIARIO DEL EXPLORADOR',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Image(logoImage, height: 52),
            ],
          ),
          pw.SizedBox(height: 26),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                  flex: 4,
                  child: _buildRouteStory(entry, sealImage),
                ),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  flex: 5,
                  child: _buildMemories(entry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _page({required pw.Widget child}) {
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      padding: const pw.EdgeInsets.all(44),
      color: PdfColors.amber50,
      child: child,
    );
  }

  static pw.Widget _buildRouteStory(
    DiaryEntry entry,
    pw.MemoryImage sealImage,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Puntos de interés de la ruta',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        if (entry.monuments.isNotEmpty)
          pw.Text(
            entry.monuments.take(5).join(' · '),
            textAlign: pw.TextAlign.center,
            maxLines: 3,
            style: const pw.TextStyle(fontSize: 15, color: PdfColors.grey700),
          ),
        pw.Spacer(),
        _buildMedal(entry.routeName, sealImage),
        pw.Spacer(),
      ],
    );
  }

  static pw.Widget _buildMedal(String routeName, pw.MemoryImage sealImage) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Image(sealImage, width: 178, height: 178, fit: pw.BoxFit.contain),
        pw.SizedBox(height: 8),
        pw.Text(
          routeName.toUpperCase(),
          textAlign: pw.TextAlign.center,
          maxLines: 1,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.brown700),
        ),
      ],
    );
  }

  static pw.Widget _buildMemories(DiaryEntry entry) {
    final photos = entry.photos.take(_maxPhotosPerRoute).toList();

    return pw.Stack(
      children: [
        pw.Positioned.fill(child: _romanPhotoFrame()),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: pw.Column(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(child: _buildMemoryTile(_photoAt(photos, 0), 0)),
                    pw.SizedBox(width: 14),
                    pw.Expanded(child: _buildMemoryTile(_photoAt(photos, 1), 1)),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(child: _buildMemoryTile(_photoAt(photos, 2), 2)),
                    pw.SizedBox(width: 14),
                    pw.Expanded(child: _buildMemoryTile(_photoAt(photos, 3), 3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _romanPhotoFrame() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.symmetric(
          horizontal: pw.BorderSide(color: PdfColors.amber300, width: 1.4),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _romanColumn(),
          _romanColumn(),
        ],
      ),
    );
  }

  static pw.Widget _romanColumn() {
    return pw.Container(
      width: 15,
      margin: const pw.EdgeInsets.symmetric(vertical: 34),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.amber300, width: 1.2),
      ),
    );
  }

  static dynamic _photoAt(List<dynamic> photos, int index) {
    return index < photos.length ? photos[index] : null;
  }

  static pw.Widget _buildMemoryTile(dynamic photo, int index) {
    final image = photo == null
        ? pw.Container(
            color: PdfColors.grey200,
            child: pw.Center(
              child: pw.Text(
                index == 0 ? 'Añadir fotos' : 'Recuerdo ${index + 1}',
                style: const pw.TextStyle(color: PdfColors.grey600),
              ),
            ),
          )
        : pw.Image(
            pw.MemoryImage(photo.readAsBytesSync()),
            fit: pw.BoxFit.cover,
          );

    return pw.Transform.rotate(
      angle: _photoTilts[index],
      child: pw.Container(
        padding: const pw.EdgeInsets.all(7),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.amber200),
        ),
        child: pw.Stack(
          children: [
            pw.Positioned.fill(child: image),
            pw.Positioned(left: 8, top: 7, child: _tapeStrip()),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tapeStrip() {
    return pw.Container(
      width: 42,
      height: 12,
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow100,
        border: pw.Border.all(color: PdfColors.amber200, width: 0.5),
      ),
    );
  }

  static const List<double> _photoTilts = [-0.025, 0.018, 0.022, -0.018];

  static pw.Widget _buildFinalPage(pw.MemoryImage logoImage) {
    return _page(
      child: pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Image(logoImage, height: 112),
            pw.SizedBox(height: 34),
            pw.Text(
              'Cada ruta que completas deja una huella en tu historia.',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 27, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              'Sigue explorando, observando y descubriendo Extremadura.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
  }
}
