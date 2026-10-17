import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';
import '../services/inventory_service.dart';
import '../utils/formatters.dart';

/// Diálogo para registrar entradas (compras) o salidas/mermas de stock.
/// Devuelve true si se guardó el movimiento.
Future<bool?> showStockAdjustDialog(
  BuildContext context,
  Product product,
  MovementType type,
) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _StockAdjustDialog(product: product, type: type),
  );
}

class _StockAdjustDialog extends StatefulWidget {
  const _StockAdjustDialog({required this.product, required this.type});

  final Product product;
  final MovementType type;

  @override
  State<_StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends State<_StockAdjustDialog> {
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  final _cost = TextEditingController();
  String? _error;
  bool _saving = false;

  bool get _isEntry => widget.type == MovementType.entrada;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final qty = parseQty(_quantity.text);
    if (qty == null || qty <= 0) {
      setState(() => _error = 'Ingresa una cantidad válida.');
      return;
    }
    final newCost = _cost.text.trim().isEmpty ? null : parseCLP(_cost.text);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<InventoryService>().adjustStock(
            widget.product,
            widget.type,
            qty,
            note: _note.text.trim(),
            newCostPrice: newCost,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on InventoryException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return AlertDialog(
      title: Text(_isEntry ? 'Entrada de stock' : 'Salida / merma'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: Theme.of(context).textTheme.titleSmall),
            Text('Stock actual: ${formatQty(p.stock)} ${p.unit}'),
            const SizedBox(height: 16),
            TextField(
              controller: _quantity,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cantidad (${p.unit})',
                errorText: _error,
              ),
              onSubmitted: (_) => _save(),
            ),
            if (_isEntry) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _cost,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nuevo costo unitario (opcional)',
                  hintText: 'Actual: ${formatCLP(p.costPrice)}',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: _isEntry ? 'Ej: compra a proveedor' : 'Ej: vencido',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: _saving ? null : _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
