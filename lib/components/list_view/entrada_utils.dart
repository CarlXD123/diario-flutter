import 'package:flutter/material.dart';

Color backgroundColorPorEmoji(String emoji) {
  switch (emoji) {
    case '😢':
      return Colors.blue.shade50;
    case '😡':
      return Colors.red.shade50;
    case '😊':
      return Colors.yellow.shade100;
    default:
      return Colors.grey.shade100;
  }
}
