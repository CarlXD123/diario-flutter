import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../security/auth_screen.dart';
import '../../screens/edit_screen.dart';
import '../../components/list_view/entrada_utils.dart';

class EntradaCard extends StatelessWidget {
  final Map<String, dynamic> entrada;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EntradaCard({
    super.key,
    required this.entrada,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entrada['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.redAccent,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        color: backgroundColorPorEmoji(entrada['emoji']),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: entrada['emoji'].toString().endsWith('.jpg') || entrada['emoji'].toString().endsWith('.png')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(entrada['emoji']),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : entrada['emoji'] != null && entrada['emoji'].toString().isNotEmpty
                ? Text(
                    entrada['emoji'],
                    style: const TextStyle(fontSize: 30),
                  )
                : const SizedBox.shrink(),

          title: Text(
            entrada['nota'].length > 2 ? '${entrada['nota'].substring(0, 2)}...' : entrada['nota'],
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy • hh:mm a').format(DateTime.parse(entrada['fecha'])),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () async {
                  if (entrada['pin'] != null) {
                    final correcto = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AuthScreen(pinCorrecto: entrada['pin'])),
                    );

                    if (correcto != true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("❌ PIN incorrecto")),
                      );
                      return;
                    }
                  }

                  final actualizado = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditScreen(entrada: entrada)),
                  );

                  if (actualizado == true) {
                    onEdit();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
