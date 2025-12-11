import 'package:flutter/material.dart';

class DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const DockButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.deepPurple.shade100 : Colors.transparent, 
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.deepPurple : Colors.grey[800], 
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.deepPurple : Colors.grey[800], // 👈 Color del texto
            ),
          ),
        ],
      ),
    );
  }
}
