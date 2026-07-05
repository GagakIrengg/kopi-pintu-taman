import '../models/inventory_item.dart';
import '../models/menu_item.dart';

class SeedData {
  static final List<MenuItem> menuItems = [

    // ── Signature Coffee ───────────────────────────────────────────
    const MenuItem(id: 'm1',  name: 'Kopi Pintu Taman',        price: 25000, category: MenuCategory.signature, temperature: MenuTemperature.both),
    const MenuItem(id: 'm2',  name: 'Kopi Creamy Aren',         price: 23000, category: MenuCategory.signature, temperature: MenuTemperature.both),
    const MenuItem(id: 'm16', name: 'Kopi Foamy Aren',          price: 25000, category: MenuCategory.signature, temperature: MenuTemperature.iced),
    const MenuItem(id: 'm17', name: 'Roasted Almond Latte',     price: 25000, category: MenuCategory.signature, temperature: MenuTemperature.both),
    const MenuItem(id: 'm18', name: 'Butterscotch Cream Latte', price: 30000, category: MenuCategory.signature, temperature: MenuTemperature.both),

    // ── Black Coffee ───────────────────────────────────────────────
    const MenuItem(id: 'm19', name: 'Mont Blanc',               price: 30000, category: MenuCategory.coffee, temperature: MenuTemperature.iced),
    const MenuItem(id: 'm3',  name: 'Kopi Apel',                price: 22000, category: MenuCategory.coffee, temperature: MenuTemperature.iced),
    const MenuItem(id: 'm20', name: 'Kopi Berry',               price: 22000, category: MenuCategory.coffee, temperature: MenuTemperature.iced),

    // ── Regular Coffee ─────────────────────────────────────────────
    const MenuItem(id: 'm5',  name: 'Americano',                price: 20000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm7',  name: 'Cafe Latte',               price: 23000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm6',  name: 'Cappuccino',               price: 23000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm21', name: 'Asian Dolce',              price: 23000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm22', name: 'Cafe Mocha',               price: 25000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm23', name: 'Vanilla Latte',            price: 25000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm24', name: 'Caramel Latte',            price: 25000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm25', name: 'Hazelnut Latte',           price: 25000, category: MenuCategory.coffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm26', name: 'Butterscotch Latte',       price: 25000, category: MenuCategory.coffee, temperature: MenuTemperature.both),

    // ── Matcha ─────────────────────────────────────────────────────
    const MenuItem(id: 'm8',  name: 'Matcha Latte',             price: 23000, category: MenuCategory.nonCoffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm27', name: 'Matcha Espresso',          price: 28000, category: MenuCategory.coffee,    temperature: MenuTemperature.iced),
    const MenuItem(id: 'm28', name: 'Strawberry Matcha',        price: 28000, category: MenuCategory.nonCoffee, temperature: MenuTemperature.iced),

    // ── Non Coffee ─────────────────────────────────────────────────
    const MenuItem(id: 'm9',  name: 'Chocolate',                price: 23000, category: MenuCategory.nonCoffee, temperature: MenuTemperature.both),
    const MenuItem(id: 'm29', name: 'Thai Tea',                 price: 20000, category: MenuCategory.nonCoffee, temperature: MenuTemperature.iced),
    const MenuItem(id: 'm30', name: 'Strawberry Milk',          price: 22000, category: MenuCategory.milkBased, temperature: MenuTemperature.iced),
    const MenuItem(id: 'm31', name: 'Mango Yakult',             price: 20000, category: MenuCategory.refresher,  temperature: MenuTemperature.iced),
    const MenuItem(id: 'm32', name: 'Lychee Yakult',            price: 20000, category: MenuCategory.refresher,  temperature: MenuTemperature.iced),
    const MenuItem(id: 'm10', name: 'Lemon Tea',                price: 18000, category: MenuCategory.refresher,  temperature: MenuTemperature.both),
    const MenuItem(id: 'm11', name: 'Lychee Tea',               price: 18000, category: MenuCategory.refresher,  temperature: MenuTemperature.both),
    const MenuItem(id: 'm33', name: 'Lemongrass Tea',           price: 18000, category: MenuCategory.refresher,  temperature: MenuTemperature.both),

    // ── Snacks ─────────────────────────────────────────────────────
    const MenuItem(id: 'm34', name: 'Donut Kampung',            price:  6000, category: MenuCategory.snack, temperature: MenuTemperature.none),
    const MenuItem(id: 'm13', name: 'Pisang Goreng',            price: 15000, category: MenuCategory.snack, temperature: MenuTemperature.none),
    const MenuItem(id: 'm12', name: 'Cireng Bumbu Rujak',       price: 15000, category: MenuCategory.snack, temperature: MenuTemperature.none),
    const MenuItem(id: 'm35', name: 'French Fries',             price: 18000, category: MenuCategory.snack, temperature: MenuTemperature.none),
    const MenuItem(id: 'm36', name: 'Mix Platter',              price: 25000, category: MenuCategory.snack, temperature: MenuTemperature.none),
    const MenuItem(id: 'm37', name: 'Chicken Wings',            price: 23000, category: MenuCategory.snack, temperature: MenuTemperature.none),

    // ── Pizza ──────────────────────────────────────────────────────
    const MenuItem(id: 'm38', name: 'Pepperoni',                price: 35000, category: MenuCategory.food, temperature: MenuTemperature.none),
    const MenuItem(id: 'm39', name: 'Supreme Cheese',           price: 35000, category: MenuCategory.food, temperature: MenuTemperature.none),
    const MenuItem(id: 'm40', name: 'Pizza Blackpepper',        price: 35000, category: MenuCategory.food, temperature: MenuTemperature.none),

    // ── Rice Bowl ──────────────────────────────────────────────────
    const MenuItem(id: 'm41', name: 'Chicken Matah',            price: 33000, category: MenuCategory.food, temperature: MenuTemperature.none),
    const MenuItem(id: 'm42', name: 'Chicken Rendang',          price: 33000, category: MenuCategory.food, temperature: MenuTemperature.none),
    const MenuItem(id: 'm43', name: 'Chicken Karage',           price: 33000, category: MenuCategory.food, temperature: MenuTemperature.none),
    const MenuItem(id: 'm44', name: 'Beef Blackpepper',         price: 33000, category: MenuCategory.food, temperature: MenuTemperature.none),
    const MenuItem(id: 'm45', name: 'Beef Yakiniku',            price: 33000, category: MenuCategory.food, temperature: MenuTemperature.none),

    // ── Add-ons ────────────────────────────────────────────────────
    const MenuItem(id: 'a1', name: 'Oatmilk',        price: 6000, category: MenuCategory.addon, temperature: MenuTemperature.none),
    const MenuItem(id: 'a2', name: 'Extra Shot',      price: 5000, category: MenuCategory.addon, temperature: MenuTemperature.none),
    const MenuItem(id: 'a3', name: 'Macchiato Foam',  price: 5000, category: MenuCategory.addon, temperature: MenuTemperature.none),
    const MenuItem(id: 'a4', name: 'Extra Foam',      price: 3000, category: MenuCategory.addon, temperature: MenuTemperature.none),
  ];

  static final List<InventoryItem> inventory = [
    const InventoryItem(id: 'i1', name: 'Biji Kopi Arabika',   unit: 'gr',  stock: 1500, minStock: 500),
    const InventoryItem(id: 'i2', name: 'Susu UHT',            unit: 'ml',  stock: 4000, minStock: 1000),
    const InventoryItem(id: 'i3', name: 'Oatmilk',             unit: 'ml',  stock: 800,  minStock: 1000),
    const InventoryItem(id: 'i4', name: 'Gula Aren',           unit: 'gr',  stock: 2000, minStock: 500),
    const InventoryItem(id: 'i5', name: 'Matcha Powder',       unit: 'gr',  stock: 300,  minStock: 100),
    const InventoryItem(id: 'i6', name: 'Cokelat Powder',      unit: 'gr',  stock: 500,  minStock: 200),
    const InventoryItem(id: 'i7', name: 'Sirup Lychee',        unit: 'ml',  stock: 500,  minStock: 300),
    const InventoryItem(id: 'i8', name: 'Sirup Vanilla',       unit: 'ml',  stock: 500,  minStock: 200),
    const InventoryItem(id: 'i9', name: 'Strawberry Puree',    unit: 'ml',  stock: 400,  minStock: 150),
    const InventoryItem(id: 'i10', name: 'Es Batu',            unit: 'pcs', stock: 100,  minStock: 30),
    const InventoryItem(id: 'i11', name: 'Cup 16oz',           unit: 'pcs', stock: 250,  minStock: 100),
    const InventoryItem(id: 'i12', name: 'Cireng (frozen)',     unit: 'pcs', stock: 40,   minStock: 20),
    const InventoryItem(id: 'i13', name: 'Kentang Goreng',     unit: 'gr',  stock: 2000, minStock: 500),
    const InventoryItem(id: 'i14', name: 'Keju Mozarela',      unit: 'gr',  stock: 500,  minStock: 200),
    const InventoryItem(id: 'i15', name: 'Ayam (dada fillet)', unit: 'gr',  stock: 2000, minStock: 500),
  ];
}