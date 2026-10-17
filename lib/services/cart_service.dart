import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartItem {
  CartItem(this.product, this.quantity);

  final Product product;
  double quantity;

  int get subtotal => (product.salePrice * quantity).round();
}

/// Carrito del punto de venta.
class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get lineCount => _items.length;
  int get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  double quantityOf(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  void add(Product product, [double quantity = 1]) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product, quantity));
    }
    notifyListeners();
  }

  void setQuantity(String productId, double quantity) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
