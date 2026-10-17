import 'package:flutter/material.dart';

import '../services/noise_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final _noise = NoiseService.instance;
  final Set<NoiseType> _loading = {};

  Future<void> _toggle(NoiseType t) async {
    setState(() => _loading.add(t));
    try {
      await _noise.toggle(t);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo reproducir: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading.remove(t));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightBackground(
      child: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<Set<NoiseType>>(
          valueListenable: _noise.playing,
          builder: (context, playing, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                const Text('Sonidos',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Toca para activar. Puedes mezclar varios a la vez.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    for (final t in NoiseType.values)
                      _SoundCard(
                        type: t,
                        playing: playing.contains(t),
                        loading: _loading.contains(t),
                        onTap: () => _toggle(t),
                      ),
                  ],
                ),
                if (playing.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  const SectionHeader(title: 'Mezcla actual'),
                  const SizedBox(height: 10),
                  for (final t in playing) _VolumeRow(type: t),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Apagar en'),
                  const SizedBox(height: 12),
                  const _TimerChips(),
                  const SizedBox(height: 24),
                  GlowButton(
                    label: 'Detener todo',
                    icon: Icons.stop_rounded,
                    color: AppColors.red,
                    onPressed: () => _noise.stopAll(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  final NoiseType type;
  final bool playing;
  final bool loading;
  final VoidCallback onTap;

  const _SoundCard({required this.type, required this.playing, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = noiseInfo[type]!;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: playing
                ? [info.color.withValues(alpha: 0.45), AppColors.card]
                : [AppColors.card, AppColors.card],
          ),
          border: Border.all(
            color: playing ? info.color : AppColors.cardBorder,
            width: 1.5,
          ),
          boxShadow: playing ? [BoxShadow(color: info.color.withValues(alpha: 0.35), blurRadius: 18)] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBox(icon: info.icon, color: info.color, size: 48),
                const Spacer(),
                if (loading)
                  const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  Icon(playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: playing ? Colors.white : AppColors.textMuted, size: 34),
              ],
            ),
            const Spacer(),
            Text(info.name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(info.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _VolumeRow extends StatefulWidget {
  final NoiseType type;
  const _VolumeRow({required this.type});

  @override
  State<_VolumeRow> createState() => _VolumeRowState();
}

class _VolumeRowState extends State<_VolumeRow> {
  @override
  Widget build(BuildContext context) {
    final info = noiseInfo[widget.type]!;
    final noise = NoiseService.instance;
    return Row(
      children: [
        Icon(info.icon, color: info.color),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(info.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
        Expanded(
          child: Slider(
            value: noise.volumeOf(widget.type),
            activeColor: info.color,
            onChanged: (v) {
              noise.setVolume(widget.type, v);
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}

class _TimerChips extends StatelessWidget {
  const _TimerChips();

  static const _options = <int?>[null, 15, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    final noise = NoiseService.instance;
    return ValueListenableBuilder<DateTime?>(
      valueListenable: noise.stopAt,
      builder: (context, stopAt, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in _options)
                  ChoiceChip(
                    label: Text(m == null ? 'Nunca' : (m >= 60 ? '${m ~/ 60} h' : '$m min')),
                    selected: m == null ? stopAt == null : false,
                    backgroundColor: AppColors.card,
                    selectedColor: AppColors.primary.withValues(alpha: 0.35),
                    side: const BorderSide(color: AppColors.cardBorder),
                    labelStyle: const TextStyle(color: Colors.white),
                    showCheckmark: false,
                    onSelected: (_) => noise.setSleepTimer(m == null ? null : Duration(minutes: m)),
                  ),
              ],
            ),
            if (stopAt != null) ...[
              const SizedBox(height: 10),
              Text('Se apagará a las ${Fmt.time(stopAt)}',
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 15)),
            ],
          ],
        );
      },
    );
  }
}
