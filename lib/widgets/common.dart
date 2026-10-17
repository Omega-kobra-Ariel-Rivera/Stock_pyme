import 'package:flutter/material.dart';

import '../models/article.dart';
import '../utils/app_colors.dart';
import 'night_background.dart';

/// Título de sección con acción opcional "Ver Todo".
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Color color;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.color = AppColors.textPrimary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null) trailing!,
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Ver Todo',
              style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

/// Botón de "Kit de Sueño" con borde de color y brillo suave.
class KitChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const KitChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Container(
            width: 132,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.16), AppColors.card],
              ),
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.4),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 14)],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Caja de ícono azul usada en tareas y tarjetas.
class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBox({super.key, required this.icon, this.color = AppColors.primary, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Fila de artículo como en "Ayuda para dormir".
class ArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  const ArticleTile({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 112,
                height: 112,
                child: ArtHero(
                  colors: article.colors,
                  icon: article.icon,
                  iconSize: 46,
                  seed: article.id.length,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${article.category} · ${article.minutes} min',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta oscura con borde.
class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const DarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor ?? AppColors.cardBorder, width: 1.4),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Botón principal azul con brillo (estilo "Comenzar").
class GlowButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color color;

  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 18)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon), const SizedBox(width: 10)],
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja inferior estándar con el estilo de la app.
Future<T?> showNightSheet<T>(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    ),
  );
}

void showComingSoon(BuildContext context, String feature) {
  showNightSheet<void>(
    context,
    child: Column(
      children: [
        const IconBox(icon: Icons.auto_awesome, size: 64),
        const SizedBox(height: 16),
        Text(feature,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'Esta función llegará en una próxima versión de NutrySleep.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 20),
        GlowButton(label: 'Entendido', onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}
