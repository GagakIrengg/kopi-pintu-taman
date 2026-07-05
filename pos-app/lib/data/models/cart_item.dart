import 'menu_item.dart';

/// Satu baris di cart. Bisa punya notes dan list add-ons.
class CartItem {
  final String lineId; // unik per baris cart
  final MenuItem menuItem;
  int quantity;
  MenuTemperature? temperature; // hot/iced kalau menu mendukung
  String? notes; // contoh: "Less Ice, Less Sugar"
  List<MenuItem> addons; // contoh: [Oatmilk, Extra Shot]

  CartItem({
    required this.lineId,
    required this.menuItem,
    this.quantity = 1,
    this.temperature,
    this.notes,
    List<MenuItem>? addons,
  }) : addons = addons ?? [];

  int get unitPrice =>
      menuItem.price + addons.fold<int>(0, (s, a) => s + a.price);

  int get lineTotal => unitPrice * quantity;
}
