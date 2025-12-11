import 'package:flutter/material.dart';

class DrawnText {
  String text;
  Offset position;
  Color color;
  double fontSize;

  DrawnText({
    required this.text,
    required this.position,
    required this.color,
    this.fontSize = 24,
  });
}
