import 'package:flutter/material.dart';

Color backgroundColorPorEmoji(String? emoji) {
  if (emoji == null || emoji.isEmpty) {
    return Colors.grey.shade200; // color neutro
  }

  switch (emoji) {
    case '😊':
      return Colors.yellow.shade100;
    case '😢':
      return Colors.blue.shade100;
    case '😡':
      return Colors.red.shade100;
    default:
      return Colors.grey.shade300;
  }
}

