import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/paywall_screen.dart';
import '../services/subscription_service.dart';

/// Aviso de días de prueba restantes o de prueba vencida.
class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    if (sub.isSubscribed) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final expired = !sub.hasAccess;
    final days = sub.trialDaysLeft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: expired ? scheme.errorContainer : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  expired ? Icons.lock_outline : Icons.workspace_premium,
                  color: expired
                      ? scheme.onErrorContainer
                      : scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    expired
                        ? 'Tu prueba gratis terminó. Suscríbete para seguir vendiendo.'
                        : 'Prueba gratis: te ${days == 1 ? 'queda 1 día' : 'quedan $days días'}.',
                    style: TextStyle(
                      color: expired
                          ? scheme.onErrorContainer
                          : scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
