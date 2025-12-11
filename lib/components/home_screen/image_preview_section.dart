import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ImagePreviewSection extends StatelessWidget {
  final File? imagen;

  const ImagePreviewSection({required this.imagen});

  @override
  Widget build(BuildContext context) {
    final customColor = Provider.of<ThemeProvider>(context).customColor;

    if (imagen == null) {
      return Text("No has seleccionado una imagen");
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: customColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          imagen!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
