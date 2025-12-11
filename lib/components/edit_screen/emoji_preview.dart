import 'dart:io';
import 'package:flutter/material.dart';

class EmojiPreview extends StatelessWidget {
  final String? path;

  const EmojiPreview({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return const SizedBox.shrink();

    final isImageFile = path!.endsWith('.jpg') || path!.endsWith('.png') || path!.endsWith('.jpeg');
    final exists = File(path!).existsSync();

    if (isImageFile && exists) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(path!), fit: BoxFit.contain),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
