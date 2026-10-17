import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;
  final int Function(StorageService s) progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    required this.progress,
  });

  int current(StorageService s) => progress(s).clamp(0, target).toInt();

  bool isUnlocked(StorageService s) => progress(s) >= target;

  double ratio(StorageService s) => current(s) / target;
}
