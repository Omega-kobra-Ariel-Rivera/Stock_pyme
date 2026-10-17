import 'package:flutter/material.dart';

import '../data/articles_data.dart';
import '../data/plan_data.dart';
import '../models/breath_pattern.dart';
import '../models/plan_task.dart';
import '../services/noise_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';
import 'achievements_screen.dart';
import 'article_screen.dart';
import 'articles_list_screen.dart';
import 'breathing_screen.dart';
import 'luna_chat_screen.dart';
import 'splash_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenSounds;
  final VoidCallback onStartSleep;

  const HomeScreen({super.key, required this.onOpenSounds, required this.onStartSleep});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    return NightBackground(
      child: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<int>(
          valueListenable: storage.changes,
          builder: (context, _, __) {
            final done = storage.completedTasks;
            final doneCount = planTasks.where((t) => done.contains(t.id)).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: [
                _Header(
                  onPro: () => showComingSoon(context, 'NutrySleep PRO'),
                  onStreak: () => _push(context, const AchievementsScreen()),
                ),
                const SizedBox(height: 18),
                const _WeekStrip(),
                const SizedBox(height: 26),
                const SectionHeader(title: 'Kit de Sueño', color: AppColors.textSecondary),
                const SizedBox(height: 16),
                _KitGrid(
                  onBreath: () => _push(context, const BreathingScreen(pattern: BreathPattern.box)),
                  onMix: onOpenSounds,
                  onArticles: () => _push(context, const ArticlesListScreen()),
                  onMeditation: () => _push(context, const BreathingScreen(pattern: BreathPattern.relax)),
                  onPulse: () => showComingSoon(context, 'Pulso'),
                  onSync: () => showComingSoon(context, 'Sync con reloj'),
                ),
                const SizedBox(height: 34),
                SectionHeader(
                  title: 'Plan para esta noche',
                  trailing: _BedtimeChip(
                    on: storage.bedtimeMode,
                    onTap: () => storage.setBedtimeMode(!storage.bedtimeMode),
                  ),
                ),
                const SizedBox(height: 18),
                _ProgressBar(done: doneCount, total: planTasks.length),
                const SizedBox(height: 18),
                for (final task in planTasks) ...[
                  _PlanTile(
                    task: task,
                    done: done.contains(task.id),
                    onTap: () => _openTask(context, task, done.contains(task.id)),
                    onToggle: () => storage.setTaskDone(task.id, !done.contains(task.id)),
                  ),
                  const SizedBox(height: 16),
                ],
                DarkCard(
                  padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                  child: Row(
                    children: [
                      const IconBox(icon: Icons.snooze_rounded),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Rastrea tu sueño',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.cardBorder,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: onStartSleep,
                        child: Text(storage.activeSleepStart == null ? 'Iniciar sueño' : 'Ver sesión',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SectionHeader(
                  title: 'Ayuda para dormir',
                  color: AppColors.textSecondary,
                  onSeeAll: () => _push(context, const ArticlesListScreen()),
                ),
                const SizedBox(height: 10),
                for (final a in articles.take(2))
                  ArticleTile(article: a, onTap: () => _push(context, ArticleScreen(article: a))),
                const SizedBox(height: 30),
                SectionHeader(
                  title: 'Luna',
                  onSeeAll: () => _push(context, const LunaChatScreen()),
                ),
                const SizedBox(height: 16),
                _LunaCard(
                  onTap: () {
                    storage.setTaskDone('luna', true);
                    _push(context, const LunaChatScreen(initialQuestion: 'Analiza mi sueño'));
                  },
                ),
                const SizedBox(height: 34),
                const SectionHeader(title: 'Consejo para Dormir del Día'),
                const SizedBox(height: 16),
                const _TipCard(),
                const SizedBox(height: 30),
                const RiveraCredit(compact: true),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- Acciones de tareas ----------------

  void _openTask(BuildContext context, PlanTask task, bool done) {
    final storage = StorageService.instance;
    showNightSheet<void>(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBox(icon: task.icon, size: 72),
              const SizedBox(width: 18),
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(task.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 17, height: 1.4)),
          const SizedBox(height: 26),
          GlowButton(
            label: 'Comenzar',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.pop(context);
              _runTask(context, task);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                storage.setTaskDone(task.id, !done);
                Navigator.pop(context);
              },
              child: Text(done ? 'Marcar como pendiente' : 'Marcar como hecho',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runTask(BuildContext context, PlanTask task) async {
    final storage = StorageService.instance;
    final messenger = ScaffoldMessenger.of(context);
    switch (task.action) {
      case PlanAction.worries:
        await _writeWorries(context);
        break;
      case PlanAction.askLuna:
        await storage.setTaskDone(task.id, true);
        if (context.mounted) _push(context, const LunaChatScreen(initialQuestion: 'Analiza mi sueño'));
        break;
      case PlanAction.whiteNoise:
        await NoiseService.instance.play(NoiseType.white);
        NoiseService.instance.setSleepTimer(const Duration(minutes: 60));
        await storage.setTaskDone(task.id, true);
        messenger.showSnackBar(const SnackBar(
            content: Text('Ruido blanco activado por 60 min. Ajústalo en Sonidos.')));
        break;
      case PlanAction.breathingReminder:
        final picked = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 22, minute: 30),
          helpText: 'Hora del ejercicio de respiración',
        );
        if (picked == null) return;
        final value = '${Fmt.two(picked.hour)}:${Fmt.two(picked.minute)}';
        await storage.setBreathingReminder(value);
        await storage.setTaskDone(task.id, true);
        messenger.showSnackBar(SnackBar(content: Text('Respiración programada para las $value')));
        break;
    }
  }

  Future<void> _writeWorries(BuildContext context) async {
    final storage = StorageService.instance;
    final controller = TextEditingController(text: storage.worriesTonight);
    final saved = await showNightSheet<bool>(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Qué tienes en la cabeza?',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Escríbelo aquí y déjalo para mañana.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 6,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Pendientes, ideas, preocupaciones...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Builder(
            builder: (ctx) => GlowButton(label: 'Guardar', onPressed: () => Navigator.pop(ctx, true)),
          ),
        ],
      ),
    );
    if (saved == true) {
      await storage.setWorriesTonight(controller.text);
      await storage.setTaskDone('worries', controller.text.trim().isNotEmpty);
    }
    controller.dispose();
  }
}

// ---------------- Widgets privados ----------------

class _Header extends StatelessWidget {
  final VoidCallback onPro;
  final VoidCallback onStreak;
  const _Header({required this.onPro, required this.onStreak});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final hour = DateTime.now().hour;
    final greet = hour < 6 || hour >= 20
        ? 'Buenas noches'
        : hour < 12
            ? 'Buenos días'
            : 'Buenas tardes';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greet,', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              Text(storage.userName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onStreak,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.primaryLight, size: 26),
                const SizedBox(width: 4),
                Text('${storage.streak}',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onPro,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [AppColors.proA, AppColors.proB]),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            ),
            child: const Text('PRO',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final today = storage.tonight;
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final d in days)
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: storage.hasSessionOn(d) ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: d == today ? AppColors.primaryLight : AppColors.cardBorder,
                    width: 2.4,
                  ),
                ),
                child: storage.hasSessionOn(d)
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(Fmt.weekdayLetters[d.weekday - 1],
                  style: TextStyle(
                      color: d == today ? Colors.white : AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
      ],
    );
  }
}

class _KitGrid extends StatelessWidget {
  final VoidCallback onBreath, onMix, onArticles, onMeditation, onPulse, onSync;

  const _KitGrid({
    required this.onBreath,
    required this.onMix,
    required this.onArticles,
    required this.onMeditation,
    required this.onPulse,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            KitChip(label: 'Aliento', icon: Icons.air_rounded, color: AppColors.pink, onTap: onBreath),
            KitChip(label: 'Mezcla', icon: Icons.tune_rounded, color: AppColors.purple, onTap: onMix),
            KitChip(label: 'Artículos', icon: Icons.menu_book_rounded, color: AppColors.teal, onTap: onArticles),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            KitChip(label: 'Meditación', icon: Icons.spa_rounded, color: AppColors.green, onTap: onMeditation),
            KitChip(label: 'Pulso', icon: Icons.monitor_heart_rounded, color: AppColors.red, onTap: onPulse),
            KitChip(label: 'Sync', icon: Icons.watch_rounded, color: AppColors.slate, onTap: onSync),
          ]),
        ],
      ),
    );
  }
}

class _BedtimeChip extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;
  const _BedtimeChip({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: on ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent,
          border: Border.all(color: on ? AppColors.primary : AppColors.cardBorder, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(Icons.bed_rounded, color: on ? AppColors.primaryLight : const Color(0xFF8C9BFF), size: 20),
            const SizedBox(width: 8),
            Text(on ? 'Encendido' : 'Apagado',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressBar({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, c) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: (c.maxWidth * value).clamp(0, c.maxWidth).toDouble(),
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Center(
            child: Text('$done/$total',
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final PlanTask task;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _PlanTile({required this.task, required this.done, required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      onTap: onTap,
      borderColor: done ? AppColors.primary.withValues(alpha: 0.75) : AppColors.cardBorder,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: [
          IconBox(icon: task.icon, color: done ? AppColors.primary : AppColors.teal),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: done ? AppColors.textMuted : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textMuted,
                decorationThickness: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.primary : Colors.transparent,
                border: Border.all(color: done ? AppColors.primary : AppColors.textMuted, width: 2),
              ),
              child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 28) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _LunaCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LunaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 138,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [AppColors.violetA, AppColors.violetB]),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: const Icon(Icons.nights_stay_rounded, color: Colors.white, size: 64),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 46),
                  ),
                  const SizedBox(width: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Analiza Tu Sueño',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tip = sleepTips[dayOfYear % sleepTips.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        constraints: const BoxConstraints(minHeight: 200),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2550), Color(0xFF0E1530), Color(0xFF243A7A)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: StarFieldPainter(count: 90, seed: 11, opacity: 0.7)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 48),
              child: Center(
                child: Text(
                  tip,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
