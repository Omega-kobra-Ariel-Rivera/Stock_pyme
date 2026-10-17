class Product {
  Product({
    required this.id,
    required this.name,
    this.barcode = '',
    this.category = '',
    this.unit = 'unidad',
    this.costPrice = 0,
    required this.salePrice,
    this.stock = 0,
    this.minStock = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String name;
  String barcode;
  String category;
  String unit;

  /// Precios en pesos chilenos (sin decimales).
  int costPrice;
  int salePrice;

  /// Admite decimales para productos a granel (kg, litro).
  double stock;
  double minStock;
  DateTime updatedAt;

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;
  int get margin => salePrice - costPrice;

  double get marginPercent =>
      salePrice == 0 ? 0 : (margin / salePrice) * 100;

  /// Copia los datos editables desde otro producto (mismo id).
  void applyFrom(Product other) {
    name = other.name;
    barcode = other.barcode;
    category = other.category;
    unit = other.unit;
    costPrice = other.costPrice;
    salePrice = other.salePrice;
    stock = other.stock;
    minStock = other.minStock;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'barcode': barcode,
        'category': category,
        'unit': unit,
        'costPrice': costPrice,
        'salePrice': salePrice,
        'stock': stock,
        'minStock': minStock,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        barcode: json['barcode'] as String? ?? '',
        category: json['category'] as String? ?? '',
        unit: json['unit'] as String? ?? 'unidad',
        costPrice: (json['costPrice'] as num?)?.toInt() ?? 0,
        salePrice: (json['salePrice'] as num?)?.toInt() ?? 0,
        stock: (json['stock'] as num?)?.toDouble() ?? 0,
        minStock: (json['minStock'] as num?)?.toDouble() ?? 0,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      );
}
