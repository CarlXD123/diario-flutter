import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AddReminderScreen extends StatefulWidget {
  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _textController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveReminder() async {
    void log(String msg) {
      debugPrint('🧪 [REMINDER] $msg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    try {
      log('Botón guardar presionado');

      if (_textController.text.trim().isEmpty ||
          _selectedDate == null ||
          _selectedTime == null) {
        log('Campos incompletos');
        return;
      }

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      log('Fecha creada: $dateTime');

      if (dateTime.isBefore(DateTime.now())) {
        log('Fecha en el pasado');
        return;
      }

      // 🟡 PEDIR PERMISO AQUÍ (SOLO CUANDO REALMENTE SE NECESITA)
      final granted =
          await NotificationService.requestPermissionIfNeeded();

      if (!granted) {
        log('Permiso de notificaciones DENEGADO');
        return;
      }

      final id = await DatabaseService.insertReminder(
        _textController.text.trim(),
        dateTime,
      );

      log('Programando notificación...');
      await NotificationService.scheduleReminder(
        id: id,
        text: _textController.text.trim(),
        dateTime: dateTime,
      );

      log('Notificación programada correctamente');

      await Future.delayed(const Duration(milliseconds: 600));
      Navigator.pop(context, true);
    } catch (e, stack) {
      debugPrint('❌ ERROR AL GUARDAR RECORDATORIO: $e');
      debugPrintStack(stackTrace: stack);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo recordatorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '¿Qué quieres recordar?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Elegir fecha'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              onPressed: _pickDate,
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(
                _selectedTime == null
                    ? 'Elegir hora'
                    : _selectedTime!.format(context),
              ),
              onPressed: _pickTime,
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Guardar recordatorio',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
