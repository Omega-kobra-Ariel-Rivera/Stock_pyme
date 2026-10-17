import 'package:flutter/material.dart';

import '../models/breath_pattern.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';

class BreathingScreen extends StatefulWidget {
  final BreathPattern pattern;
  const BreathingScreen({super.key, required this.pattern});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _running = false;
  int _cycles = 0;

  BreathPattern get p => widget.pattern;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: p.cycle))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && _running) {
          setState(() => _cycles++);
          StorageService.instance.addBreathCycle();
          _ctrl.forward(from: 0);
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _ctrl.forward();
    } else {
      _ctrl.stop();
    }
  }

  void _reset() {
    _ctrl.reset();
    setState(() {
      _running = false;
      _cycles = 0;
    });
  }

  /// Devuelve (fase, segundos restantes, escala del círculo).
  (String, int, double) _state(double v) {
    final t = v * p.cycle;
    const small = 0.55;
    const big = 1.0;
    if (t < p.inhale) {
      final k = t / p.inhale;
      return ('Inhala', (p.inhale - t).ceil(), small + (big - small) * Curves.easeInOut.transform(k));
    }
    if (t < p.inhale + p.holdIn) {
      return ('Mantén', (p.inhale + p.holdIn - t).ceil(), big);
    }
    if (t < p.inhale + p.holdIn + p.exhale) {
      final k = (t - p.inhale - p.holdIn) / p.exhale;
      return ('Exhala', (p.inhale + p.holdIn + p.exhale - t).ceil(), big - (big - small) * Curves.easeInOut.transform(k));
    }
    return ('Pausa', (p.cycle - t).ceil(), small);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(p.name)),
      body: NightBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Text(p.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 17)),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final (phase, secs, scale) = _state(_ctrl.value);
                      final label = _running || _ctrl.value > 0 ? phase : 'Listo';
                      return Center(
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: p.color.withValues(alpha: 0.25), width: 2),
                                ),
                              ),
                              Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 260,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [p.color.withValues(alpha: 0.85), p.color.withValues(alpha: 0.25)],
                                    ),
                                    boxShadow: [BoxShadow(color: p.color.withValues(alpha: 0.45), blurRadius: 40)],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(label,
                                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                                  if (_running || _ctrl.value > 0)
                                    Text('$secs',
                                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text('Ciclos completados: $_cycles',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 18),
                GlowButton(
                  label: _running ? 'Pausar' : 'Comenzar',
                  icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: p.color,
                  onPressed: _toggle,
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reiniciar', style: TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
