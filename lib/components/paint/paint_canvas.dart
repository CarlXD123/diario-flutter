import 'package:flutter/material.dart';
import '../paint/drawn_line.dart';
import '../paint/drawn_text.dart';

class PaintCanvas extends CustomPainter {
  final List<DrawnLine> lines;
  final List<DrawnText> texts; 

  PaintCanvas({required this.lines, required this.texts});

  @override
  void paint(Canvas canvas, Size size) {
    // Dibuja líneas
    for (var line in lines) {
      if (line.points == null || line.points!.length < 2) continue;

      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = line.strokeWidth
        ..isAntiAlias = true;

      for (int i = 0; i < line.points!.length - 1; i++) {
        canvas.drawLine(line.points![i], line.points![i + 1], paint);
      }
    }

    // Dibuja textos y emojis
    for (var textItem in texts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: textItem.text,
          style: TextStyle(
            color: textItem.color,
            fontSize: textItem.fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, textItem.position);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
