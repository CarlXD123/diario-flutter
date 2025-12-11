import 'package:flutter/material.dart';

class DrawnLine {
  List<Offset>? points;
  final Color color;
  final double strokeWidth;

  DrawnLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}
