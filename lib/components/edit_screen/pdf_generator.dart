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

    // 🔹 Cargar imagen si existe
    pw.MemoryImage? pwImage;
    final imagePath = entrada['emoji'];
    if (imagePath != null && File(imagePath).existsSync()) {
      final bytes = await File(imagePath).readAsBytes();
      pwImage = pw.MemoryImage(bytes);
    }

    // 🔹 Función para dividir texto muy largo en trozos que quepan en la página
    List<String> splitText(String text, int chunkLength) {
      List<String> chunks = [];
      int start = 0;
      while (start < text.length) {
        int end = start + chunkLength;
        if (end > text.length) end = text.length;
        chunks.add(text.substring(start, end));
        start = end;
      }
      return chunks;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final widgets = <pw.Widget>[];

          // 🔹 Imagen al inicio
          if (pwImage != null) {
            widgets.add(
              pw.Center(
                child: pw.Image(
                  pwImage,
                  height: 150, // altura segura
                  fit: pw.BoxFit.contain,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // 🔹 Título
          widgets.add(
            pw.Text(
              "Entrada del Diario",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 12));

          // 🔹 Texto dividido en párrafos
          final paragraphs = contenido.split("\n");
          for (var p in paragraphs) {
            if (p.trim().isEmpty) continue;

            // ⚡ Para párrafos muy largos, los dividimos en trozos de 500 caracteres aprox
            final chunks = splitText(p, 500);
            for (var chunk in chunks) {
              widgets.add(
                pw.Text(
                  chunk,
                  style: const pw.TextStyle(fontSize: 16),
                  softWrap: true,
                ),
              );
              widgets.add(pw.SizedBox(height: 8));
            }
          }

          return widgets;
        },
      ),
    );

    // 🔹 Guardar archivo en temp
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/diario_${entrada['id']}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
