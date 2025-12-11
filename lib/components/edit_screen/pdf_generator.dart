import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PDFGenerator {
  static Future<void> generate(Map<String, dynamic> entrada, String contenido, BuildContext context) async {
    final pdf = pw.Document();
    final imagePath = entrada['emoji'];
    final imageFile = (imagePath != null && File(imagePath).existsSync()) ? File(imagePath) : null;
    final pwImage = imageFile != null ? pw.MemoryImage(await imageFile.readAsBytes()) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (pwImage != null)
                pw.Center(
                  child: pw.Container(
                    height: 200,
                    width: 200,
                    child: pw.Image(pwImage, fit: pw.BoxFit.contain),
                  ),
                ),
              pw.SizedBox(height: 20),
              pw.Text("Entrada del Diario", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text(contenido, style: pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/diario_${entrada['id']}.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("📄 PDF generado: ${file.path}")),
    );

    await OpenFile.open(file.path);
  }
}
