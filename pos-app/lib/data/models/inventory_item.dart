enum StockStatus { ok, low, out }

class InventoryItem {
  final String id;
  final String name;
  final String unit; // pcs, gr, ml, kg, l
  final double stock;
  final double minStock;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.minStock,
  });

  StockStatus get status {
    if (stock <= 0) return StockStatus.out;
    if (stock <= minStock) return StockStatus.low;
    return StockStatus.ok;
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
        'stock': stock,
        'min_stock': minStock,
      };

  static InventoryItem fromMap(Map<String, Object?> m) => InventoryItem(
        id: m['id'] as String,
        name: m['name'] as String,
        unit: m['unit'] as String,
        stock: (m['stock'] as num).toDouble(),
        minStock: (m['min_stock'] as num).toDouble(),
      );

  InventoryItem copyWith({
    String? name,
    String? unit,
    double? stock,
    double? minStock,
  }) =>
      InventoryItem(
        id: id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        stock: stock ?? this.stock,
        minStock: minStock ?? this.minStock,
      );
}
