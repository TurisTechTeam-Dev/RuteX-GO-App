/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
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

  static Future<void> generateExplorerBook({
    required flutter.BuildContext context,
    required List<DiaryEntry> allRoutes,
    required String userName,
    required String userRank,
  }) async {
    final pdf = pw.Document();
    final logoBytes = await rootBundle.load('assets/Logo_Color_Rutexgo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final extremaduraBytes = await rootBundle.load(
      'assets/Mapa_fondo_Extremadura.png',
    );
    final extremaduraImage = pw.MemoryImage(
      extremaduraBytes.buffer.asUint8List(),
    );

    try {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => _buildCover(
            logoImage: logoImage,
            userName: userName,
            userRank: userRank,
          ),
        ),
      );

      for (final entry in allRoutes) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (context) => _buildRoutePage(
              entry: entry,
              extremaduraImage: extremaduraImage,
              userName: userName,
              userRank: userRank,
            ),
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'diario_explorador_rutexgo.pdf',
        format: PdfPageFormat.a4,
        dynamicLayout: false,
      );
    } catch (e) {
      flutter.debugPrint("Error PDF: $e");
    }
  }

  static pw.Widget _buildCover({
    required pw.MemoryImage logoImage,
    required String userName,
    required String userRank,
  }) {
    return _sheet(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Image(logoImage, height: 86),
          pw.SizedBox(height: 40),
          pw.Text(
            'MI DIARIO DE\nEXPLORADOR',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 34, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 24),
          pw.Divider(indent: 60, endIndent: 60, color: PdfColors.grey700),
          pw.SizedBox(height: 16),
          pw.Text(
            userName,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Rango: $userRank', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 48),
          pw.Text(
            'Extremadura en tus manos',
            style: pw.TextStyle(
              fontSize: 13,
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
    required pw.MemoryImage extremaduraImage,
    required String userName,
    required String userRank,
  }) {
    return _sheet(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            children: [
              pw.Image(extremaduraImage, height: 38),
              pw.SizedBox(width: 12),
              pw.Text(
                'DIARIO DEL\nEXPLORADOR',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Datos del Explorador',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text('Nombre: $userName'),
          pw.Text('Rango: $userRank'),
          pw.SizedBox(height: 18),
          pw.Center(child: _buildMedal(entry.routeName)),
          if (entry.monuments.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              entry.monuments.take(4).join(' · '),
              maxLines: 2,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            'MIS RECUERDOS',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Expanded(child: _buildMemories(entry)),
        ],
      ),
    );
  }

  static pw.Widget _sheet({required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(28),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: child,
    );
  }

  static pw.Widget _buildMedal(String routeName) {
    return pw.Container(
      width: 128,
      height: 128,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        color: PdfColors.amber100,
        border: pw.Border.all(color: PdfColors.amber800, width: 4),
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'RUTA',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.amber900,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text('★', style: const pw.TextStyle(fontSize: 32)),
            pw.Text(
              'COMPLETADA',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.amber900,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              routeName.toUpperCase(),
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.amber900),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildMemories(DiaryEntry entry) {
    final photos = entry.photos.take(_maxPhotosPerRoute).toList();

    return pw.GridView(
      crossAxisCount: 2,
      childAspectRatio: 0.86,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(_maxPhotosPerRoute, (index) {
        final photo = index < photos.length ? photos[index] : null;
        return _buildMemoryTile(photo, index);
      }),
    );
  }

  static pw.Widget _buildMemoryTile(dynamic photo, int index) {
    final image = photo == null
        ? pw.Container(
            color: PdfColors.grey200,
            child: pw.Center(
              child: pw.Text(
                'Recuerdo ${index + 1}',
                style: const pw.TextStyle(color: PdfColors.grey600),
              ),
            ),
          )
        : pw.Image(
            pw.MemoryImage(photo.readAsBytesSync()),
            fit: pw.BoxFit.cover,
          );

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Expanded(child: image),
          pw.SizedBox(height: 5),
          pw.Text(
            photo == null ? 'Recuerdo ${index + 1}' : 'Foto ${index + 1}',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
