import 'package:flutter/material.dart';

import '../data/achievements_data.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StorageService.instance;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Rachas y logros')),
      body: NightBackground(
        child: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: s.changes,
            builder: (context, _, __) {
              final unlocked = AchievementService.unlockedCount();
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  _StreakHero(current: s.streak, best: s.bestStreak),
                  const SizedBox(height: 26),
                  SectionHeader(
                    title: 'Logros',
                    trailing: Text('$unlocked/${achievements.length}',
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                    children: [for (final a in achievements) AchievementCard(achievement: a)],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  final int current;
  final int best;
  const _StreakHero({required this.current, required this.best});

  @override
  Widget build(BuildContext context) {
    final next = [3, 7, 14, 30].firstWhere((t) => t > current, orElse: () => 0);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [AppColors.violetA, AppColors.violetB]),
        boxShadow: [BoxShadow(color: AppColors.violetB.withValues(alpha: 0.35), blurRadius: 24)],
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$current ${current == 1 ? 'noche' : 'noches'}',
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                const Text('Racha actual', style: TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 8),
                Text('Mejor racha: $best',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                if (next > 0)
                  Text('Faltan ${next - current} para la racha de $next',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final s = StorageService.instance;
    final a = achievement;
    final done = a.isUnlocked(s);
    final color = done ? a.color : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: done ? a.color.withValues(alpha: 0.7) : AppColors.cardBorder, width: 1.4),
        boxShadow: done ? [BoxShadow(color: a.color.withValues(alpha: 0.2), blurRadius: 16)] : null,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: done
                      ? RadialGradient(colors: [a.color.withValues(alpha: 0.55), a.color.withValues(alpha: 0.12)])
                      : null,
                  color: done ? null : AppColors.bg,
                  border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
                ),
                child: Icon(a.icon, color: done ? Colors.white : AppColors.textMuted, size: 34),
              ),
              if (!done)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(a.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: done ? Colors.white : AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(a.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.3)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: a.ratio(s),
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(done ? a.color : AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(done ? '¡Desbloqueado!' : '${a.current(s)}/${a.target}',
              style: TextStyle(color: done ? a.color : AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Diálogo de celebración al desbloquear logros.
Future<void> showAchievementUnlocked(BuildContext context, List<Achievement> list) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 8),
            Text(list.length == 1 ? '¡Logro desbloqueado!' : '¡${list.length} logros desbloqueados!',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            for (final a in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    IconBox(icon: a.icon, color: a.color, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          Text(a.description,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            GlowButton(label: '¡Genial!', onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}
