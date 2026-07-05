import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/inventory_item.dart';
import 'data_providers.dart';

/// Daftar ingredient yang stoknya rendah atau habis.
/// Auto-recalc setiap kali inventoryProvider berubah.
final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inv = ref.watch(inventoryProvider).valueOrNull ?? const [];
  return inv
      .where((i) =>
          i.status == StockStatus.low || i.status == StockStatus.out)
      .toList();
});

/// Flag agar dialog low-stock hanya muncul sekali per sesi (setelah login).
/// Direset saat logout.
final lowStockDialogShownProvider = StateProvider<bool>((_) => false);
