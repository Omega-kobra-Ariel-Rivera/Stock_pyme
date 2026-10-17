import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/paywall_screen.dart';
import '../services/subscription_service.dart';

/// Devuelve true si el usuario puede usar funciones de pago.
/// Si la prueba terminó, abre la pantalla de suscripción.
Future<bool> ensureAccess(BuildContext context) async {
  final subscription = context.read<SubscriptionService>();
  if (subscription.hasAccess) return true;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const PaywallScreen()),
  );
  return subscription.hasAccess;
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? scheme.error : null,
      ),
    );
}
