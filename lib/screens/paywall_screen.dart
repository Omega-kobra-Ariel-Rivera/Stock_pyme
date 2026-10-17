import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/subscription_service.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _features = [
    (Icons.qr_code_scanner, 'Productos ilimitados con escáner de código de barras'),
    (Icons.point_of_sale, 'Punto de venta con cálculo de vuelto'),
    (Icons.notifications_active_outlined, 'Alertas de stock bajo'),
    (Icons.bar_chart, 'Reportes de ventas, ganancias y más vendidos'),
    (Icons.table_view_outlined, 'Exporta tus datos a Excel'),
  ];

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final String status;
    if (sub.isSubscribed) {
      status = '¡Tu suscripción está activa! Gracias por confiar en ${AppConstants.appName}.';
    } else if (sub.inTrial) {
      status = 'Te ${sub.trialDaysLeft == 1 ? 'queda 1 día' : 'quedan ${sub.trialDaysLeft} días'} de prueba gratis.';
    } else {
      status =
          'Tu prueba gratis terminó. Suscríbete para seguir vendiendo y controlando tu stock. Tus datos siguen guardados.';
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const Center(child: AppLogo(size: 84)),
            const SizedBox(height: 12),
            Text(
              '${AppConstants.appName} Pro',
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(status, textAlign: TextAlign.center, style: text.bodyLarge),
            const SizedBox(height: 24),
            for (final (icon, label) in _features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(icon, color: scheme.primary),
                    const SizedBox(width: 14),
                    Expanded(child: Text(label, style: text.bodyLarge)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      sub.priceLabel,
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Se renueva automáticamente cada mes. Cancela cuando quieras desde Google Play.',
                      textAlign: TextAlign.center,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            if (sub.error != null) ...[
              const SizedBox(height: 12),
              Text(
                sub.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed:
                  sub.isSubscribed || sub.loading ? null : () => sub.subscribe(),
              child: sub.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(sub.isSubscribed ? 'Suscripción activa' : 'Suscribirme'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: sub.loading ? null : () => sub.restore(),
              child: const Text('Ya pagué: restaurar compra'),
            ),
            if (!sub.isAndroid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'En la versión web, la suscripción se contrata desde la app Android.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
