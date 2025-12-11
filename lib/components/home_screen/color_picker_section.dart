import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ColorPickerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<ThemeProvider>(context).customColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "🎨 ¿Cómo te sientes? Elige tu color que te representa :3",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: Colors.primaries.map((color) {
            return GestureDetector(
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setColor(color);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
