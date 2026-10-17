class SleepSession {
  final DateTime start;
  final DateTime end;

  /// Calidad percibida de 1 a 5.
  final int quality;

  const SleepSession({
    required this.start,
    required this.end,
    required this.quality,
  });

  Duration get duration => end.difference(start);

  double get hours => duration.inMinutes / 60.0;

  /// Noche a la que pertenece la sesión (si empezó de madrugada, cuenta
  /// como la noche anterior).
  DateTime get night {
    final d = start.hour < 12 ? start.subtract(const Duration(days: 1)) : start;
    return DateTime(d.year, d.month, d.day);
  }

  Map<String, dynamic> toJson() => {
        's': start.millisecondsSinceEpoch,
        'e': end.millisecondsSinceEpoch,
        'q': quality,
      };

  factory SleepSession.fromJson(Map<String, dynamic> j) => SleepSession(
        start: DateTime.fromMillisecondsSinceEpoch(j['s'] as int),
        end: DateTime.fromMillisecondsSinceEpoch(j['e'] as int),
        quality: (j['q'] as int?) ?? 3,
      );
}
