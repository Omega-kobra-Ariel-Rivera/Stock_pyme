import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/inventory_service.dart';
import '../utils/access_guard.dart';
import '../utils/formatters.dart';
import '../widgets/checkout_sheet.dart';
import '../widgets/empty_state.dart';
import 'scanner_screen.dart';

/// Punto de venta: buscar o escanear, armar el carrito y cobrar.
class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _search = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final cart = context.read<CartService>();
    final available = product.stock - cart.quantityOf(product.id);
    if (available <= 0) {
      showMessage(
        context,
        'Sin stock suficiente de ${product.name} (quedan ${formatQty(product.stock)}).',
        error: true,
      );
      return;
    }
    // Productos a granel con menos de 1 kg disponible: agrega lo que queda.
    cart.add(product, available < 1 ? available : 1);
    _search.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  Future<void> _scanAdd() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code == null || !mounted) return;
    final product = context.read<InventoryService>().findByBarcode(code);
    if (product == null) {
      showMessage(context, 'No hay productos con el código $code.',
          error: true);
      return;
    }
    _addToCart(product);
  }

  Future<void> _editQuantity(CartItem item) async {
    final controller = TextEditingController(text: formatQty(item.quantity));
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.product.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Cantidad (${item.product.unit})',
            helperText: 'Disponible: ${formatQty(item.product.stock)}',
          ),
          onSubmitted: (v) => Navigator.of(dialogContext).pop(parseQty(v)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(parseQty(controller.text)),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    if (value > item.product.stock) {
      showMessage(context, 'Solo hay ${formatQty(item.product.stock)} disponibles.',
          error: true);
      return;
    }
    context.read<CartService>().setQuantity(item.product.id, value);
  }

  void _increment(CartItem item) {
    if (item.quantity + 1 > item.product.stock) {
      showMessage(context, 'No hay más stock de ${item.product.name}.',
          error: true);
      return;
    }
    context.read<CartService>().setQuantity(item.product.id, item.quantity + 1);
  }

  void _decrement(CartItem item) {
    final next = item.quantity - 1;
    context.read<CartService>().setQuantity(item.product.id, next < 0 ? 0 : next);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Quitar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) context.read<CartService>().clear();
  }

  Future<void> _checkout() async {
    final cart = context.read<CartService>();
    if (cart.isEmpty || _processing) return;
    if (!await ensureAccess(context) || !mounted) return;

    final result = await showCheckoutSheet(context, cart.total);
    if (result == null || !mounted) return;

    setState(() => _processing = true);
    try {
      final sale = await context
          .read<InventoryService>()
          .registerSale(cart.items, result.method);
      cart.clear();
      if (!mounted) return;
      final cash = result.cashReceived;
      final change = cash == null ? '' : ' · Vuelto: ${formatCLP(cash - sale.total)}';
      showMessage(context,
          'Venta N° ${sale.number} registrada: ${formatCLP(sale.total)}$change');
    } on InventoryException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryService>();
    final cart = context.watch<CartService>();
    final query = _search.text.trim();
    final suggestions =
        query.isEmpty ? <Product>[] : inv.search(query).take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vender'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Vaciar carrito',
              icon: const Icon(Icons.remove_shopping_cart_outlined),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (suggestions.length == 1) _addToCart(suggestions.first);
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar producto',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Escanear',
                  iconSize: 28,
                  onPressed: _scanAdd,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
          ),
          if (suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    for (final p in suggestions)
                      ListTile(
                        dense: true,
                        enabled: p.stock > 0,
                        title: Text(p.name),
                        subtitle: Text(p.stock > 0
                            ? 'Stock: ${formatQty(p.stock)} ${p.unit}'
                            : 'Sin stock'),
                        trailing: Text(formatCLP(p.salePrice),
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        onTap: () => _addToCart(p),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: cart.isEmpty
                ? const EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Carrito vacío',
                    message: 'Escanea o busca productos para agregarlos a la venta.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _CartLine(
                      item: cart.items[i],
                      onIncrement: () => _increment(cart.items[i]),
                      onDecrement: () => _decrement(cart.items[i]),
                      onEdit: () => _editQuantity(cart.items[i]),
                    ),
                  ),
          ),
          _CheckoutBar(
            total: cart.total,
            lines: cart.lineCount,
            processing: _processing,
            onCheckout: cart.isEmpty ? null : _checkout,
          ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall),
                Text(
                  '${formatCLP(item.product.salePrice)} c/${item.product.unit} · ${formatCLP(item.subtotal)}',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Quitar uno',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onDecrement,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onEdit,
            child: Container(
              constraints: const BoxConstraints(minWidth: 44),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatQty(item.quantity),
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Agregar uno',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.lines,
    required this.processing,
    required this.onCheckout,
  });

  final int total;
  final int lines;
  final bool processing;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$lines ${lines == 1 ? 'producto' : 'productos'}',
                        style: text.bodySmall),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCLP(total),
                        style: text.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: FilledButton.icon(
                  onPressed: processing ? null : onCheckout,
                  icon: processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_outlined),
                  label: const Text('Cobrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
