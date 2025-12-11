import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorSelector({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selectedColor == color
                    ? Border.all(color: Colors.black, width: 2.5)
                    : Border.all(color: Colors.transparent),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
