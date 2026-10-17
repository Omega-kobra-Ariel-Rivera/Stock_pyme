import 'package:flutter/material.dart';

enum PlanAction { worries, askLuna, whiteNoise, breathingReminder }

class PlanTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final PlanAction action;

  const PlanTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
  });
}
