import '../data/models/menu_item.dart';

/// Identifier khusus untuk item custom (diketik manual kasir di POS).
///
/// Konvensi: semua TransactionItem hasil custom menu memakai
/// menuItemId == kCustomMenuId. Saat agregasi data untuk SAW nanti,
/// filter `WHERE menu_item_id != 'custom'` agar item insidental ini
/// TIDAK ikut me-ranking rekomendasi (menjaga integritas data skripsi).
const String kCustomMenuId = 'custom';

/// Membuat MenuItem "sintetis" untuk item custom, supaya bisa masuk ke
/// cart lewat alur addItem yang sudah ada (tanpa mengubah logika cart).
///
/// - id selalu kCustomMenuId
/// - tidak punya temperature (none) & tidak punya add-on
/// - kategori snack hanya sebagai placeholder; TIDAK dipakai untuk apa pun
///   yang berhubungan dengan menu resmi / SAW.
MenuItem buildCustomMenuItem({
  required String name,
  required int price,
}) {
  return MenuItem(
    id: kCustomMenuId,
    name: name,
    price: price,
    category: MenuCategory.snack,
    temperature: MenuTemperature.none,
    isAvailable: true,
  );
}

/// Cek apakah sebuah menuItemId berasal dari custom menu.
bool isCustomMenuId(String menuItemId) => menuItemId == kCustomMenuId;
