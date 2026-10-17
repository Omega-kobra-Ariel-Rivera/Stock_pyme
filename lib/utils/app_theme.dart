import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.card,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primaryLight,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      );
}

/// Utilidades de formato de fecha/hora sin dependencias externas.
class Fmt {
  Fmt._();

  static String two(int n) => n.toString().padLeft(2, '0');

  static String time(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${two(m)}m';
  }

  static String clock(Duration d) =>
      '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';

  static const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const weekdayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];

  static String shortDate(DateTime d) =>
      '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
}
