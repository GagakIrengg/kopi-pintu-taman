import '../data/models/inventory_item.dart';

/// Hasil evaluasi transisi stok setelah sebuah transaksi.
class LowStockTransition {
  /// Bahan yang BARU menjadi low/out akibat transaksi ini
  /// (sebelumnya aman, dan belum pernah dinotif).
  final List<InventoryItem> newlyLow;

  /// Bahan yang kembali aman (di atas threshold) — untuk di-"lupakan"
  /// dari daftar yang sudah dinotif (supaya bisa notif lagi nanti).
  final List<String> recoveredIds;

  LowStockTransition(this.newlyLow, this.recoveredIds);
}

/// Logika murni (tanpa Flutter) untuk #5: tentukan bahan mana yang
/// baru transisi jadi low/out, dan mana yang sudah pulih.
///
/// - [current]            : daftar inventory TERBARU (sesudah deduction)
/// - [alreadyNotifiedIds] : id bahan yang sudah pernah dinotif
class LowStockEvaluator {
  static LowStockTransition evaluate({
    required List<InventoryItem> current,
    required Set<String> alreadyNotifiedIds,
  }) {
    final newlyLow = <InventoryItem>[];
    final recovered = <String>[];

    for (final item in current) {
      final isLowOrOut = item.status == StockStatus.low ||
          item.status == StockStatus.out;

      if (isLowOrOut) {
        // low/out sekarang. Notif HANYA kalau belum pernah dinotif.
        if (!alreadyNotifiedIds.contains(item.id)) {
          newlyLow.add(item);
        }
      } else {
        // status aman lagi. Kalau sebelumnya tercatat sudah dinotif,
        // tandai untuk di-reset supaya bisa notif lagi di masa depan.
        if (alreadyNotifiedIds.contains(item.id)) {
          recovered.add(item.id);
        }
      }
    }

    return LowStockTransition(newlyLow, recovered);
  }
}
