import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sleep_session.dart';
import '../services/noise_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  final _storage = StorageService.instance;
  late DateTime _start;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    final active = _storage.activeSleepStart;
    if (active == null) {
      _start = DateTime.now();
      _storage.setActiveSleepStart(_start);
    } else {
      _start = active;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _finish() async {
    final end = DateTime.now();
    final elapsed = end.difference(_start);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (elapsed.inMinutes < 1) {
      await _storage.setActiveSleepStart(null);
      messenger.showSnackBar(const SnackBar(content: Text('Sesión muy corta: no se guardó.')));
      navigator.pop();
      return;
    }

    final quality = await showNightSheet<int>(context, child: const _QualityPicker());
    if (quality == null) return;
    await _storage.addSession(SleepSession(start: _start, end: end, quality: quality));
    await _storage.setActiveSleepStart(null);
    await NoiseService.instance.stopAll();
    messenger.showSnackBar(SnackBar(content: Text('Noche guardada: ${Fmt.duration(elapsed)} 🌙')));
    navigator.pop();
  }

  Future<void> _cancel() async {
    await _storage.setActiveSleepStart(null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _now.difference(_start);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Durmiendo'),
        actions: [
          TextButton(
            onPressed: _cancel,
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: NightBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.bedtime_rounded, color: AppColors.primaryLight, size: 64),
                const SizedBox(height: 16),
                Text(Fmt.time(_now),
                    style: const TextStyle(color: Colors.white, fontSize: 84, fontWeight: FontWeight.w200)),
                Text('Durmiendo desde las ${Fmt.time(_start)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 17)),
                const SizedBox(height: 12),
                Text(Fmt.clock(elapsed),
                    style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()])),
                const Spacer(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sonidos para esta noche',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<Set<NoiseType>>(
                  valueListenable: NoiseService.instance.playing,
                  builder: (context, playing, _) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in NoiseType.values)
                        FilterChip(
                          selected: playing.contains(t),
                          label: Text(noiseInfo[t]!.name),
                          avatar: Icon(noiseInfo[t]!.icon, size: 18, color: noiseInfo[t]!.color),
                          backgroundColor: AppColors.card,
                          selectedColor: noiseInfo[t]!.color.withValues(alpha: 0.3),
                          side: BorderSide(color: noiseInfo[t]!.color.withValues(alpha: 0.5)),
                          labelStyle: const TextStyle(color: Colors.white),
                          showCheckmark: false,
                          onSelected: (_) => NoiseService.instance.toggle(t),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GlowButton(label: 'Despertar y guardar', icon: Icons.wb_sunny_rounded, onPressed: _finish),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QualityPicker extends StatelessWidget {
  const _QualityPicker();

  static const _options = [
    (1, '😫', 'Muy mal'),
    (2, '😕', 'Mal'),
    (3, '😐', 'Normal'),
    (4, '🙂', 'Bien'),
    (5, '😴', 'Excelente'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('¿Cómo dormiste?',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final o in _options)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context, o.$1),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    children: [
                      Text(o.$2, style: const TextStyle(fontSize: 38)),
                      const SizedBox(height: 4),
                      Text(o.$3, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
