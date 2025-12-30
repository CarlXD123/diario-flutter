import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final data = await DatabaseService.getReminders();
    setState(() {
      _reminders = data;
    });
  }

  Future<void> _openAddReminder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddReminderScreen()),
    );

    if (result == true) {
      _loadReminders(); // 👈 AQUÍ VA
    }
  }

  Future<void> _deleteReminder(int id) async {
    // 1️⃣ cancelar notificación
    await NotificationService.cancelReminder(id);

    // 2️⃣ borrar de la BD
    await DatabaseService.deleteReminder(id);

    // 3️⃣ recargar lista
    _loadReminders();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio eliminado 🗑️')),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: const Text('¿Seguro que deseas eliminar este recordatorio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      _deleteReminder(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReminder,
        child: const Icon(Icons.add),
      ),
      body: _reminders.isEmpty
          ? const Center(child: Text('No tienes recordatorios'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (_, i) {
                final r = _reminders[i];
                return ListTile(
                  leading: const Icon(Icons.alarm),
                  title: Text(r['text']),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      r['scheduled_at'],
                    ).toString(),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(r['id']),
                  ),
                );
              },
            ),
    );
  }
}
