import 'package:flutter/material.dart';

import '../data/achievements_data.dart';
import '../services/achievement_service.dart';
import '../services/noise_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';
import 'achievements_screen.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final storage = StorageService.instance;
    final ctrl = TextEditingController(text: storage.userName);
    final ok = await showNightSheet<bool>(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu nombre',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 17),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),
          Builder(builder: (ctx) => GlowButton(label: 'Guardar', onPressed: () => Navigator.pop(ctx, true))),
        ],
      ),
    );
    if (ok == true) await storage.setUserName(ctrl.text);
    ctrl.dispose();
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Borrar todos los datos'),
        content: const Text('Se eliminarán tus noches registradas, el plan y tus ajustes. No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await NoiseService.instance.stopAll();
      await StorageService.instance.clearAll();
    }
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
            final name = storage.userName;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                const Text('Perfil',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                DarkCard(
                  onTap: () => _editName(context),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.violetA, AppColors.violetB]),
                        ),
                        child: Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                            Text('Racha: ${storage.streak} noches · ${storage.sessions.length} registros',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DarkCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AchievementsScreen()),
                  ),
                  child: Row(
                    children: [
                      const IconBox(icon: Icons.emoji_events_rounded, color: Color(0xFFFFC94D)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rachas y logros',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            Text('${AchievementService.unlockedCount()} de ${achievements.length} desbloqueados · mejor racha ${storage.bestStreak}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Meta de sueño'),
                const SizedBox(height: 12),
                DarkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${storage.goalHours.toStringAsFixed(1)} horas por noche',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      Slider(
                        value: storage.goalHours,
                        min: 5,
                        max: 10,
                        divisions: 10,
                        label: '${storage.goalHours.toStringAsFixed(1)} h',
                        onChanged: (v) => storage.setGoalHours(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Ajustes'),
                const SizedBox(height: 12),
                DarkCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: storage.bedtimeMode,
                        onChanged: storage.setBedtimeMode,
                        activeColor: AppColors.primary,
                        title: const Text('Modo hora de dormir', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Indica en el inicio que tu rutina nocturna está activa',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.alarm, color: AppColors.primaryLight),
                        title: const Text('Respiración programada', style: TextStyle(color: Colors.white)),
                        trailing: Text(storage.breathingReminder ?? 'Sin definir',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                        title: const Text('Borrar todos los datos', style: TextStyle(color: AppColors.red)),
                        onTap: () => _confirmClear(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/icon/logo.png', width: 64, height: 64),
                      const SizedBox(height: 6),
                      const Text('NutrySleep v1.0.0',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      const RiveraCredit(compact: true),
                      const SizedBox(height: 4),
                      const Text('Familia NutryScan',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
