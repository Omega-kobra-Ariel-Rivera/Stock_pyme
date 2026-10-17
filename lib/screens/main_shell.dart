import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'sleep_tracking_screen.dart';
import 'sounds_screen.dart';
import 'stats_screen.dart';

/// Observador de rutas para saber cuándo la pantalla principal vuelve a verse.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with RouteAware {
  int _index = 0;
  final List<Achievement> _pending = [];
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    StorageService.instance.changes.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onDataChanged());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    StorageService.instance.changes.removeListener(_onDataChanged);
    super.dispose();
  }

  /// Se vuelve a la pantalla principal tras cerrar otra pantalla u hoja.
  @override
  void didPopNext() => _flushPending();

  void _onDataChanged() {
    _pending.addAll(AchievementService.checkNew());
    WidgetsBinding.instance.addPostFrameCallback((_) => _flushPending());
  }

  /// Muestra la celebración solo cuando la pantalla principal está visible,
  /// para no interferir con otras pantallas abiertas.
  Future<void> _flushPending() async {
    if (!mounted || _celebrating || _pending.isEmpty) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _celebrating = true;
    final list = List<Achievement>.from(_pending);
    _pending.clear();
    await showAchievementUnlocked(context, list);
    _celebrating = false;
  }

  void _go(int i) => setState(() => _index = i);

  void _startSleep() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SleepTrackingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenSounds: () => _go(1), onStartSleep: _startSleep),
          const SoundsScreen(),
          const StatsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _SleepFab(onTap: _startSleep),
      bottomNavigationBar: Container(
        height: 84 + MediaQuery.paddingOf(context).bottom,
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: AppColors.navBar,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.6)),
        ),
        child: Row(
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Inicio', selected: _index == 0, onTap: () => _go(0)),
            _NavItem(icon: Icons.music_note_rounded, label: 'Sonidos', selected: _index == 1, onTap: () => _go(1)),
            const SizedBox(width: 110),
            _NavItem(icon: Icons.insights_rounded, label: 'Estadísticas', selected: _index == 2, onTap: () => _go(2)),
            _NavItem(icon: Icons.account_circle_outlined, label: 'Perfil', selected: _index == 3, onTap: () => _go(3)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepFab extends StatelessWidget {
  final VoidCallback onTap;
  const _SleepFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 150,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.55), blurRadius: 24, spreadRadius: 1),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bedtime_rounded, color: Colors.white, size: 36),
              SizedBox(width: 10),
              Text(
                'Iniciar\nSueño',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
