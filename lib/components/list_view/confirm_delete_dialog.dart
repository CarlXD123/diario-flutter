import 'package:flutter/material.dart';

Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("¿Eliminar recuerdo?"),
      content: Text("Esta acción no se puede deshacer."),
      actions: [
        TextButton(
          child: Text("Cancelar"),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: Text("Eliminar"),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
}
