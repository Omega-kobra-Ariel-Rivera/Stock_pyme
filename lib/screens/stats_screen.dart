import 'package:flutter/material.dart';

import '../models/sleep_session.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    return NightBackground(
      child: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<int>(
          valueListenable: storage.changes,
          builder: (context, _, __) {
            final sessions = storage.sessions;
            final goal = storage.goalHours;
            final tonight = storage.tonight;
            final days = List.generate(7, (i) => tonight.subtract(Duration(days: 6 - i)));
            final hoursByDay = <double>[
              for (final d in days)
                sessions
                    .where((s) => StorageService.dayKey(s.night) == StorageService.dayKey(d))
                    .fold<double>(0, (a, s) => a + s.hours),
            ];
            final recorded = hoursByDay.where((h) => h > 0).toList();
            final avg = recorded.isEmpty ? 0.0 : recorded.reduce((a, b) => a + b) / recorded.length;
            final week = sessions.where((s) => !s.night.isBefore(days.first)).toList();
            final avgQ = week.isEmpty
                ? 0.0
                : week.map((s) => s.quality).reduce((a, b) => a + b) / week.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                const Text('Estadísticas',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Últimos 7 días',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Promedio', value: avg == 0 ? '—' : '${avg.toStringAsFixed(1)} h', icon: Icons.bedtime_rounded, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Meta', value: '${goal.toStringAsFixed(1)} h', icon: Icons.flag_rounded, color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Racha (mejor ${storage.bestStreak})', value: '${storage.streak} noches', icon: Icons.water_drop, color: AppColors.primaryLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Calidad', value: avgQ == 0 ? '—' : '${avgQ.toStringAsFixed(1)} / 5', icon: Icons.star_rounded, color: const Color(0xFFFFC94D))),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionHeader(title: 'Horas por noche'),
                const SizedBox(height: 14),
                DarkCard(child: _BarChart(days: days, hours: hoursByDay, goal: goal)),
                const SizedBox(height: 26),
                const SectionHeader(title: 'Historial'),
                const SizedBox(height: 10),
                if (sessions.isEmpty)
                  const DarkCard(
                    child: Text(
                      'Aún no hay noches registradas. Toca "Iniciar Sueño" al acostarte para empezar.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  )
                else
                  for (final s in sessions.reversed.take(20)) _SessionRow(session: s),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<DateTime> days;
  final List<double> hours;
  final double goal;

  const _BarChart({required this.days, required this.hours, required this.goal});

  @override
  Widget build(BuildContext context) {
    const chartHeight = 170.0;
    final maxH = [goal + 1, ...hours].reduce((a, b) => a > b ? a : b);
    final goalY = chartHeight * (goal / maxH);
    return Column(
      children: [
        SizedBox(
          height: chartHeight + 22,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: goalY,
                child: Row(
                  children: [
                    Expanded(child: Container(height: 1.5, color: AppColors.green.withValues(alpha: 0.7))),
                    const SizedBox(width: 6),
                    Text('${goal.toStringAsFixed(0)}h',
                        style: const TextStyle(color: AppColors.green, fontSize: 12)),
                  ],
                ),
              ),
              Positioned.fill(
                right: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < hours.length; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (hours[i] > 0)
                              Text(hours[i].toStringAsFixed(1),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 22,
                              height: hours[i] <= 0 ? 4 : chartHeight * (hours[i] / maxH),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: hours[i] >= goal
                                      ? [AppColors.primary, AppColors.primaryLight]
                                      : [AppColors.violetA, AppColors.violetB],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Row(
            children: [
              for (final d in days)
                Expanded(
                  child: Text(Fmt.weekdays[d.weekday - 1],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final SleepSession session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    const faces = ['😫', '😕', '😐', '🙂', '😴'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DarkCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(faces[(session.quality - 1).clamp(0, 4)], style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Fmt.shortDate(session.night),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('${Fmt.time(session.start)} → ${Fmt.time(session.end)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            Text(Fmt.duration(session.duration),
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
