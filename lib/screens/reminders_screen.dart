import 'package:flutter/material.dart';
import '../services/database_service.dart';
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
                );
              },
            ),
    );
  }
}
