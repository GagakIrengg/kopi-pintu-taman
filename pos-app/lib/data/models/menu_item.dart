/// Tipe penyajian sebuah menu.
enum MenuTemperature { hot, iced, both, none }

/// Kategori menu - termasuk add-ons sebagai kategori.
enum MenuCategory {
  signature,
  coffee,
  nonCoffee,
  milkBased,
  refresher,
  snack,
  food,
  addon;

  String get label => switch (this) {
        MenuCategory.signature => 'Signature',
        MenuCategory.coffee => 'Coffee',
        MenuCategory.nonCoffee => 'Non-Coffee',
        MenuCategory.milkBased => 'Milk Based',
        MenuCategory.refresher => 'Refreshers',
        MenuCategory.snack => 'Snacks',
        MenuCategory.food => 'Food',
        MenuCategory.addon => 'Add-ons',
      };

  static MenuCategory fromString(String s) =>
      MenuCategory.values.firstWhere((e) => e.name == s,
          orElse: () => MenuCategory.coffee);
}

class MenuItem {
  final String id;
  final String name;
  final int price;
  final MenuCategory category;
  final MenuTemperature temperature;
  final bool isAvailable;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.temperature,
    this.isAvailable = true,
  });

  bool get isAddon => category == MenuCategory.addon;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category.name,
        'temperature': temperature.name,
        'is_available': isAvailable ? 1 : 0,
      };

  static MenuItem fromMap(Map<String, Object?> m) => MenuItem(
        id: m['id'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toInt(),
        category: MenuCategory.fromString(m['category'] as String),
        temperature: MenuTemperature.values
            .firstWhere((e) => e.name == m['temperature']),
        isAvailable: (m['is_available'] as int) == 1,
      );

  MenuItem copyWith({
    String? name,
    int? price,
    MenuCategory? category,
    MenuTemperature? temperature,
    bool? isAvailable,
  }) =>
      MenuItem(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        category: category ?? this.category,
        temperature: temperature ?? this.temperature,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}
