import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // ✅ Permiso de notificaciones (Android 13+)
    await androidPlugin?.requestNotificationsPermission();

    // ✅ Canal (NO recrearlo cada vez con otro ID)
    const channel = AndroidNotificationChannel(
      'reminders_channel', // ⬅ ID SIMPLE Y ESTABLE
      'Recordatorios',
      description: 'Recordatorios del diario',
      importance: Importance.high,
    );

    await androidPlugin?.createNotificationChannel(channel);
  }

  static Future<void> scheduleReminder({
    required int id,
    required String text,
    required DateTime dateTime,
  }) async {
    await _notifications.zonedSchedule(
      id,
      'Recordatorio 📝',
      text,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel_PROD', // ⬅ MISMO ID
          'Recordatorios',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

   // 👇 ESTE ES EL NUEVO
  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }
}
