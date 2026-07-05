/// Jenis komponen dalam resep menu:
/// - ingredient   : langsung bahan mentah (inventory_items)
/// - intermediate : bahan olahan (intermediate_products)
enum RecipeComponentType {
  ingredient,
  intermediate;

  static RecipeComponentType fromString(String s) =>
      RecipeComponentType.values.firstWhere((e) => e.name == s,
          orElse: () => RecipeComponentType.ingredient);
}

/// Temperature scope sebuah baris resep menu.
/// 'all' dipakai untuk menu non-suhu (snack/food) atau komponen
/// yang sama untuk hot & iced.
class RecipeTemp {
  static const hot = 'hot';
  static const iced = 'iced';
  static const all = 'all';
}

/// Satu baris resep menu/add-on -> komponen (bahan mentah / bahan olahan).
class MenuRecipe {
  final String id;
  final String menuId;
  final RecipeComponentType componentType;
  final String componentId;
  final String temperature; // 'hot' | 'iced' | 'all'
  final double quantity;

  const MenuRecipe({
    required this.id,
    required this.menuId,
    required this.componentType,
    required this.componentId,
    required this.temperature,
    required this.quantity,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'menu_id': menuId,
        'component_type': componentType.name,
        'component_id': componentId,
        'temperature': temperature,
        'quantity': quantity,
      };

  static MenuRecipe fromMap(Map<String, Object?> m) => MenuRecipe(
        id: m['id'] as String,
        menuId: m['menu_id'] as String,
        componentType:
            RecipeComponentType.fromString(m['component_type'] as String),
        componentId: m['component_id'] as String,
        temperature: m['temperature'] as String,
        quantity: (m['quantity'] as num).toDouble(),
      );

  MenuRecipe copyWith({double? quantity}) => MenuRecipe(
        id: id,
        menuId: menuId,
        componentType: componentType,
        componentId: componentId,
        temperature: temperature,
        quantity: quantity ?? this.quantity,
      );
}
