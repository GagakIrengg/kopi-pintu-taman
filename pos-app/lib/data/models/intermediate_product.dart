/// Lapis 2 — "Bahan Olahan" (produk antara).
/// Contoh: Shot Espresso (unit: shot), Matcha Base (unit: base).
class IntermediateProduct {
  final String id;
  final String name;
  final String unit;

  const IntermediateProduct({
    required this.id,
    required this.name,
    required this.unit,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
      };

  static IntermediateProduct fromMap(Map<String, Object?> m) =>
      IntermediateProduct(
        id: m['id'] as String,
        name: m['name'] as String,
        unit: m['unit'] as String,
      );

  IntermediateProduct copyWith({String? name, String? unit}) =>
      IntermediateProduct(
        id: id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
      );
}

/// Satu baris resep Bahan Olahan -> bahan mentah.
/// Contoh: Shot Espresso butuh 9 gr Biji Kopi Arabika.
class IntermediateRecipe {
  final String id;
  final String intermediateId;
  final String ingredientId;
  final double quantity;

  const IntermediateRecipe({
    required this.id,
    required this.intermediateId,
    required this.ingredientId,
    required this.quantity,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'intermediate_id': intermediateId,
        'ingredient_id': ingredientId,
        'quantity': quantity,
      };

  static IntermediateRecipe fromMap(Map<String, Object?> m) =>
      IntermediateRecipe(
        id: m['id'] as String,
        intermediateId: m['intermediate_id'] as String,
        ingredientId: m['ingredient_id'] as String,
        quantity: (m['quantity'] as num).toDouble(),
      );

  IntermediateRecipe copyWith({double? quantity}) => IntermediateRecipe(
        id: id,
        intermediateId: intermediateId,
        ingredientId: ingredientId,
        quantity: quantity ?? this.quantity,
      );
}
