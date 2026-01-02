import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class PDFGenerator {
  static Future<File> generate(
    Map<String, dynamic> entrada,
    String contenido,
  ) async {
    final pdf = pw.Document();

    final imagePath = entrada['emoji'];
    final imageFile =
        (imagePath != null && File(imagePath).existsSync())
            ? File(imagePath)
            : null;

    final pwImage = imageFile != null
        ? pw.MemoryImage(await imageFile.readAsBytes())
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          if (pwImage != null)
            pw.Center(
              child: pw.Image(
                pwImage,
                height: 200,
                fit: pw.BoxFit.contain,
              ),
            ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Entrada del Diario",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 12),

          pw.Text(
            contenido,
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/diario_${entrada['id']}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
