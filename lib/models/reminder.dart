class Reminder {
  final int? id;
  final String text;
  final DateTime scheduledAt;

  Reminder({
    this.id,
    required this.text,
    required this.scheduledAt,
  });
}
