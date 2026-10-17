import 'package:flutter/material.dart';

class BreathPattern {
  final String name;
  final String subtitle;
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;
  final Color color;

  const BreathPattern({
    required this.name,
    required this.subtitle,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
    required this.color,
  });

  int get cycle => inhale + holdIn + exhale + holdOut;

  static const box = BreathPattern(
    name: 'Aliento',
    subtitle: 'Respiración cuadrada 4-4-4-4 para calmar la mente',
    inhale: 4,
    holdIn: 4,
    exhale: 4,
    holdOut: 4,
    color: Color(0xFFE0578A),
  );

  static const relax = BreathPattern(
    name: 'Meditación',
    subtitle: 'Respiración 4-7-8 para relajar el cuerpo antes de dormir',
    inhale: 4,
    holdIn: 7,
    exhale: 8,
    holdOut: 0,
    color: Color(0xFF3FAE5A),
  );
}
