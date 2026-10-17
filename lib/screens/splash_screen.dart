import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/night_background.dart';
import 'main_shell.dart';

/// Pantalla de inicio animada con el logo de NutrySleep y el crédito de
/// Rivera Systems.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logo;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _logo = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOutBack));
    _text = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1, curve: Curves.easeOut));
    _ctrl.forward();
    Future<void>.delayed(const Duration(milliseconds: 2600), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Column(
                children: [
                  const Spacer(flex: 3),
                  Transform.scale(
                    scale: 0.6 + 0.4 * _logo.value,
                    child: Opacity(
                      opacity: _logo.value.clamp(0.0, 1.0),
                      child: Image.asset('assets/icon/logo.png', width: 190, height: 190),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: _text.value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - _text.value)),
                      child: const Column(
                        children: [
                          Text('NutrySleep',
                              style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          SizedBox(height: 6),
                          Text('Duerme mejor cada noche',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  Opacity(opacity: _text.value, child: const RiveraCredit()),
                  const SizedBox(height: 28),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Crédito "Hecho por Rivera Systems" con el logo oficial de la marca.
class RiveraCredit extends StatelessWidget {
  final bool compact;
  const RiveraCredit({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (!compact) {
      return Column(
        children: [
          const Text('Hecho por',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 6),
          Image.asset('assets/brand/rivera_logo.png', width: 150),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/brand/rivera_shield.png', width: 46),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hecho por',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1)),
            Text('Rivera Systems',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
