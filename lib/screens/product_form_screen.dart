import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/inventory_service.dart';
import '../utils/access_guard.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/id_generator.dart';
import 'scanner_screen.dart';

/// Crear o editar un producto.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product, this.initialBarcode});

  final Product? product;
  final String? initialBarcode;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _barcode;
  late final TextEditingController _category;
  late final TextEditingController _cost;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _minStock;
  late String _unit;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _barcode =
        TextEditingController(text: p?.barcode ?? widget.initialBarcode ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _cost = TextEditingController(text: p == null ? '' : '${p.costPrice}');
    _price = TextEditingController(text: p == null ? '' : '${p.salePrice}');
    _stock = TextEditingController(text: p == null ? '' : formatQty(p.stock));
    _minStock =
        TextEditingController(text: p == null ? '' : formatQty(p.minStock));
    _unit = p?.unit ?? AppConstants.units.first;
    if (!AppConstants.units.contains(_unit)) _unit = AppConstants.units.first;
  }

  @override
  void dispose() {
    for (final c in [_name, _barcode, _category, _cost, _price, _stock, _minStock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code != null && mounted) setState(() => _barcode.text = code);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final inv = context.read<InventoryService>();
    final product = Product(
      id: widget.product?.id ?? newId(),
      name: _name.text.trim(),
      barcode: _barcode.text.trim(),
      category: _category.text.trim(),
      unit: _unit,
      costPrice: parseCLP(_cost.text) ?? 0,
      salePrice: parseCLP(_price.text) ?? 0,
      stock: parseQty(_stock.text) ?? 0,
      minStock: parseQty(_minStock.text) ?? 0,
    );
    try {
      if (_isEditing) {
        await inv.updateProduct(product);
      } else {
        await inv.addProduct(product);
      }
      if (!mounted) return;
      showMessage(context, _isEditing ? 'Producto actualizado' : 'Producto creado');
      Navigator.of(context).pop();
    } on InventoryException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, e.message, error: true);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  String? _validQty(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final q = parseQty(v);
    return (q == null || q < 0) ? 'Número no válido' : null;
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryService>();
    final scheme = Theme.of(context).colorScheme;
    final cost = parseCLP(_cost.text) ?? 0;
    final price = parseCLP(_price.text) ?? 0;
    final margin = price - cost;
    final marginPct = price == 0 ? 0.0 : margin / price * 100;
    final categories = inv.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Código de barras',
                suffixIcon: IconButton(
                  tooltip: 'Escanear',
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scan,
                ),
              ),
              validator: (v) =>
                  inv.isBarcodeTaken(v ?? '', exceptId: widget.product?.id)
                      ? 'Este código ya está en uso'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Categoría', hintText: 'Ej: Bebidas, Abarrotes'),
            ),
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in categories)
                    ActionChip(
                      label: Text(c),
                      onPressed: () => setState(() => _category.text = c),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _unit,
              decoration: const InputDecoration(labelText: 'Unidad de venta'),
              items: [
                for (final u in AppConstants.units)
                  DropdownMenuItem(value: u, child: Text(u)),
              ],
              onChanged: (v) => setState(() => _unit = v ?? _unit),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cost,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        labelText: 'Costo', prefixText: r'$ '),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        labelText: 'Precio venta *', prefixText: r'$ '),
                    validator: (v) => (parseCLP(v ?? '') ?? 0) <= 0
                        ? 'Ingresa un precio'
                        : null,
                  ),
                ),
              ],
            ),
            if (price > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Ganancia por ${_unit == 'unidad' ? 'unidad' : _unit}: ${formatCLP(margin)} (${formatPercent(marginPct)})',
                  style: TextStyle(
                    color: margin < 0 ? scheme.error : scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: _isEditing ? 'Stock actual' : 'Stock inicial'),
                    validator: _validQty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minStock,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Stock mínimo'),
                    validator: _validQty,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                'Te avisaremos cuando el stock llegue al mínimo.',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
            ),
          ],
        ),
      ),
    );
  }
}
