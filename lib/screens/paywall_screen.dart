import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/subscription_service.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';

/// Pantalla de suscripción: pago mensual con Mercado Pago.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  static const Color _mercadoPagoBlue = Color(0xFF009EE3);

  static const _features = [
    (Icons.qr_code_scanner, 'Productos ilimitados con escáner de código de barras'),
    (Icons.point_of_sale, 'Punto de venta con cálculo de vuelto'),
    (Icons.notifications_active_outlined, 'Alertas de stock bajo'),
    (Icons.bar_chart, 'Reportes de ventas, ganancias y más vendidos'),
    (Icons.table_view_outlined, 'Exporta tus datos a Excel'),
  ];

  late final TextEditingController _email = TextEditingController(
    text: context.read<SubscriptionService>().payerEmail,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final String status;
    if (sub.isSubscribed) {
      status =
          'Tu suscripción está activa. Gracias por confiar en ${AppConstants.appName}.';
    } else if (sub.inTrial) {
      status =
          'Te ${sub.trialDaysLeft == 1 ? 'queda 1 día' : 'quedan ${sub.trialDaysLeft} días'} de prueba gratis.';
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
              style: text.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(status, textAlign: TextAlign.center, style: text.bodyLarge),
            const SizedBox(height: 24),
            for (final (icon, label) in _features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon,
                          size: 20, color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(label, style: text.bodyLarge)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.primary, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      sub.priceLabel,
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cobro automático cada mes con Mercado Pago. Cancela cuando quieras desde tu cuenta de Mercado Pago.',
                      textAlign: TextAlign.center,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (sub.isSubscribed)
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Suscripción activa'),
              )
            else ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !sub.loading,
                decoration: const InputDecoration(
                  labelText: 'Correo de tu cuenta de Mercado Pago',
                  hintText: 'nombre@correo.cl',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _mercadoPagoBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: sub.loading ? null : () => sub.subscribe(_email.text),
                icon: sub.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline),
                label: const Text('Pagar con Mercado Pago'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: sub.loading ? null : () => sub.checkPayment(),
                child: const Text('Ya pagué: revisar mi pago'),
              ),
            ],
            if (sub.info != null) ...[
              const SizedBox(height: 8),
              Text(
                sub.info!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.primary),
              ),
            ],
            if (sub.error != null) ...[
              const SizedBox(height: 8),
              Text(
                sub.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.error),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Pago seguro procesado por Mercado Pago',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Center(child: MadeByRivera()),
          ],
        ),
      ),
    );
  }
}
