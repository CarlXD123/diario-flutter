import 'package:flutter/material.dart';
import '../../screens/list_view.dart';

class ButtonsSection extends StatelessWidget {
  final VoidCallback onSeleccionarImagen;
  final VoidCallback onGuardar;

  const ButtonsSection({
    required this.onSeleccionarImagen,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListViewScreen()),
            );
          },
          icon: Icon(Icons.menu_book),
          label: Text("📖 Ver Recuerdos"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onSeleccionarImagen,
          icon: Icon(Icons.image),
          label: Text("Seleccionar imagen de emoción"),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Colors.teal,
          ),
        ),
      ],
    );
  }
}
