import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/inventory_service.dart';
import '../utils/formatters.dart';
import '../widgets/app_logo.dart';
import '../widgets/product_tile.dart';
import '../widgets/stat_card.dart';
import '../widgets/trial_banner.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  /// Cambia de pestaña: 1 = productos, 2 = vender, 3 = reportes.
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryService>();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final low = inv.lowStockProducts;
    final recent = inv.sales.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(inv.businessName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TrialBanner(),
          Text('Hoy', style: text.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                icon: Icons.payments_outlined,
                label: 'Ventas (${inv.todaySalesCount})',
                value: formatCLP(inv.todayTotal),
              ),
              StatCard(
                icon: Icons.trending_up,
                label: 'Ganancia',
                value: formatCLP(inv.todayProfit),
              ),
              StatCard(
                icon: Icons.warehouse_outlined,
                label: 'Valor del inventario',
                value: formatCLP(inv.inventoryValue),
              ),
              StatCard(
                icon: Icons.warning_amber_rounded,
                label: 'Productos con stock bajo',
                value: '${low.length}',
                highlight: low.isNotEmpty,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => onNavigate(2),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Nueva venta'),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Stock bajo',
            actionLabel: low.isEmpty ? null : 'Ver productos',
            onAction: () => onNavigate(1),
          ),
          if (inv.products.isEmpty)
            _InfoCard(
              icon: Icons.inventory_2_outlined,
              message: 'Aún no tienes productos. Agrégalos en la pestaña Productos.',
              actionLabel: 'Ir a productos',
              onAction: () => onNavigate(1),
            )
          else if (low.isEmpty)
            const _InfoCard(
              icon: Icons.check_circle_outline,
              message: 'Todo en orden: ningún producto bajo el mínimo.',
            )
          else
            Card(
              child: Column(
                children: [
                  for (final p in low.take(5)) ProductTile(product: p),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Últimas ventas',
            actionLabel: recent.isEmpty ? null : 'Ver reportes',
            onAction: () => onNavigate(3),
          ),
          if (recent.isEmpty)
            const _InfoCard(
              icon: Icons.receipt_long_outlined,
              message: 'Las ventas que registres aparecerán aquí.',
            )
          else
            Card(
              child: Column(
                children: [
                  for (final sale in recent)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.secondaryContainer,
                        foregroundColor: scheme.onSecondaryContainer,
                        child: const Icon(Icons.receipt_outlined, size: 20),
                      ),
                      title: Text(formatCLP(sale.total),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          'N° ${sale.number} · ${formatDateTime(sale.date)} · ${sale.paymentMethod.label}'),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          const MadeByRivera(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            if (actionLabel != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
