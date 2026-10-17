import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/plan_data.dart';
import '../models/sleep_session.dart';

/// Persistencia local simple. Notifica cambios a la UI vía [changes].
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late SharedPreferences _p;
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  void _notify() => changes.value++;

  static String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// La "noche" actual: antes del mediodía cuenta como la noche anterior.
  DateTime get tonight {
    final n = DateTime.now();
    final d = n.hour < 12 ? n.subtract(const Duration(days: 1)) : n;
    return DateTime(d.year, d.month, d.day);
  }

  // ---------- Plan para esta noche ----------
  Set<String> get completedTasks =>
      (_p.getStringList('plan_${dayKey(tonight)}') ?? <String>[]).toSet();

  Future<void> setTaskDone(String id, bool done) async {
    final set = completedTasks;
    if (done) {
      set.add(id);
    } else {
      set.remove(id);
    }
    await _p.setStringList('plan_${dayKey(tonight)}', set.toList());
    if (set.length >= planTasks.length) {
      final nights = (_p.getStringList('plan_complete') ?? <String>[]).toSet()
        ..add(dayKey(tonight));
      await _p.setStringList('plan_complete', nights.toList());
    }
    _notify();
  }

  String get worriesTonight => _p.getString('worries_${dayKey(tonight)}') ?? '';

  Future<void> setWorriesTonight(String text) async {
    await _p.setString('worries_${dayKey(tonight)}', text);
    _notify();
  }

  // ---------- Sesiones de sueño ----------
  List<SleepSession> get sessions {
    final raw = _p.getString('sessions');
    if (raw == null || raw.isEmpty) return <SleepSession>[];
    final list = jsonDecode(raw) as List<dynamic>;
    final result = list
        .map((e) => SleepSession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  Future<void> addSession(SleepSession s) async {
    final list = sessions..add(s);
    await _p.setString(
        'sessions', jsonEncode(list.map((e) => e.toJson()).toList()));
    _notify();
  }

  DateTime? get activeSleepStart {
    final v = _p.getInt('active_start');
    return v == null ? null : DateTime.fromMillisecondsSinceEpoch(v);
  }

  Future<void> setActiveSleepStart(DateTime? d) async {
    if (d == null) {
      await _p.remove('active_start');
    } else {
      await _p.setInt('active_start', d.millisecondsSinceEpoch);
    }
    _notify();
  }

  /// Noches seguidas con registro, terminando en la noche actual o la anterior.
  int get streak {
    final nights = sessions.map((s) => dayKey(s.night)).toSet();
    var day = tonight;
    if (!nights.contains(dayKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (nights.contains(dayKey(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  bool hasSessionOn(DateTime night) =>
      sessions.any((s) => dayKey(s.night) == dayKey(night));

  // ---------- Datos para logros ----------
  int get totalNights => sessions.map((s) => dayKey(s.night)).toSet().length;

  /// Mejor racha histórica de noches seguidas.
  int get bestStreak {
    final nights = sessions.map((s) => s.night).toSet().toList()..sort();
    var best = 0;
    var cur = 0;
    DateTime? prev;
    for (final n in nights) {
      final consecutive =
          prev != null && DateTime(prev.year, prev.month, prev.day + 1) == n;
      cur = consecutive ? cur + 1 : 1;
      if (cur > best) best = cur;
      prev = n;
    }
    return best;
  }

  /// Noches en que se durmió al menos la meta de horas.
  int get goalNights {
    final byNight = <String, double>{};
    for (final s in sessions) {
      final k = dayKey(s.night);
      byNight[k] = (byNight[k] ?? 0) + s.hours;
    }
    return byNight.values.where((h) => h >= goalHours).length;
  }

  int get planCompleteNights => (_p.getStringList('plan_complete') ?? <String>[]).length;

  int get breathCycles => _p.getInt('breath_cycles') ?? 0;

  Future<void> addBreathCycle() async {
    await _p.setInt('breath_cycles', breathCycles + 1);
    _notify();
  }

  Set<String> get seenAchievements => (_p.getStringList('ach_seen') ?? <String>[]).toSet();

  /// Guarda logros ya celebrados (sin notificar, para no generar bucles).
  Future<void> markAchievementsSeen(Iterable<String> ids) async {
    await _p.setStringList('ach_seen', {...seenAchievements, ...ids}.toList());
  }

  // ---------- Perfil y ajustes ----------
  String get userName => _p.getString('name') ?? 'Soñador';

  Future<void> setUserName(String v) async {
    await _p.setString('name', v.trim().isEmpty ? 'Soñador' : v.trim());
    _notify();
  }

  double get goalHours => _p.getDouble('goal') ?? 8.0;

  Future<void> setGoalHours(double v) async {
    await _p.setDouble('goal', v);
    _notify();
  }

  bool get bedtimeMode => _p.getBool('bedtime') ?? false;

  Future<void> setBedtimeMode(bool v) async {
    await _p.setBool('bedtime', v);
    _notify();
  }

  String? get breathingReminder => _p.getString('breath_reminder');

  Future<void> setBreathingReminder(String v) async {
    await _p.setString('breath_reminder', v);
    _notify();
  }

  Future<void> clearAll() async {
    await _p.clear();
    _notify();
  }
}
