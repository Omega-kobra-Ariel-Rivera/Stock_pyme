import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Logo de StockPyme. [withBackground] usa el ícono completo con fondo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40, this.withBackground = true});

  final double size;
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      withBackground ? AppConstants.logoPath : AppConstants.logoForegroundPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Firma "Hecho por Rivera Systems".
class MadeByRivera extends StatelessWidget {
  const MadeByRivera({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      'Hecho por ${AppConstants.company}',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color ?? scheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
    );
  }
}
