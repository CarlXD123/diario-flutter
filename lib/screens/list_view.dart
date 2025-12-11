import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../components/list_view/entrada_card.dart';
import '../components/list_view/confirm_delete_dialog.dart';

class ListViewScreen extends StatefulWidget {
  @override
  _ListViewScreenState createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  List<Map<String, dynamic>> _entradas = [];

  @override
  void initState() {
    super.initState();
    _cargarEntradas();
  }

  Future<void> _cargarEntradas() async {
    final datos = await DatabaseService.getEntradas();
    setState(() {
      _entradas = datos;
    });
  }

  Future<bool?> _eliminarEntrada(int id, int index) async {
    final confirm = await showDeleteConfirmationDialog(context);
    if (confirm == true) {
      await DatabaseService.deleteEntrada(id);
      await _cargarEntradas();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🗑️ Recuerdo eliminado"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tus recuerdos")),
      body: _entradas.isEmpty
          ? Center(child: Text("No hay recuerdos aún 😢"))
          : ListView.builder(
              itemCount: _entradas.length,
              itemBuilder: (context, index) {
                return EntradaCard(
                  entrada: _entradas[index],
                  onEdit: _cargarEntradas,
                  onDelete: () => _eliminarEntrada(_entradas[index]['id'], index),
                );
              },
            ),
    );
  }
}
