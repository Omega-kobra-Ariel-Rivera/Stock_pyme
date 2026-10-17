import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Fondo degradado nocturno con estrellas suaves.
class NightBackground extends StatelessWidget {
  final Widget child;
  const NightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bg, AppColors.bg],
          stops: [0, 0.35, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: StarFieldPainter(count: 40, seed: 3, opacity: 0.25)),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final int count;
  final int seed;
  final double opacity;

  const StarFieldPainter({this.count = 60, this.seed = 1, this.opacity = 0.8});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final r = 0.4 + rnd.nextDouble() * 1.3;
      paint.color = Colors.white.withValues(alpha: opacity * (0.3 + rnd.nextDouble() * 0.7));
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter old) =>
      old.count != count || old.seed != seed || old.opacity != opacity;
}

/// Ilustración generada para artículos (sin imágenes externas).
class ArtHero extends StatelessWidget {
  final List<Color> colors;
  final IconData icon;
  final double iconSize;
  final int seed;

  const ArtHero({
    super.key,
    required this.colors,
    required this.icon,
    this.iconSize = 90,
    this.seed = 7,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: StarFieldPainter(count: 70, seed: seed, opacity: 0.9)),
          Align(
            alignment: const Alignment(0.55, -0.6),
            child: FractionallySizedBox(
              widthFactor: 0.12,
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF4D6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFF4D6).withValues(alpha: 0.5),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.35),
            child: Icon(
              icon,
              size: iconSize,
              color: Colors.white.withValues(alpha: 0.92),
              shadows: [
                Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
