enum PaymentMethod { cash, qris }

enum TransactionStatus { held, paid, voided }

/// Preset alasan pembatalan (Opsi 3).
/// Dikelompokkan: operasional vs sinyal ketidakpuasan (untuk analisis skripsi).
enum VoidReason {
  salahInputMenu,
  salahJumlah,
  pelangganBatal,
  stokHabis,
  refundKomplainKualitas,
  refundSalahPesanan,
  lainnya;

  String get label => switch (this) {
        VoidReason.salahInputMenu => 'Salah input menu',
        VoidReason.salahJumlah => 'Salah jumlah / qty',
        VoidReason.pelangganBatal => 'Pelanggan batal sebelum dibuat',
        VoidReason.stokHabis => 'Stok bahan habis',
        VoidReason.refundKomplainKualitas =>
          'Refund - komplain rasa/kualitas',
        VoidReason.refundSalahPesanan => 'Refund - salah pesanan',
        VoidReason.lainnya => 'Lainnya',
      };

  /// true = sinyal ketidakpuasan pelanggan (relevan untuk analisis sentimen
  /// di skripsi), false = murni operasional.
  bool get isDissatisfactionSignal => switch (this) {
        VoidReason.refundKomplainKualitas => true,
        VoidReason.refundSalahPesanan => true,
        _ => false,
      };

  static VoidReason? fromName(String? s) {
    if (s == null) return null;
    for (final v in VoidReason.values) {
      if (v.name == s) return v;
    }
    return null;
  }
}

class TransactionItem {
  final String id;
  final String menuItemId;
  final String menuName;
  final int unitPrice;
  final int quantity;
  final String? temperature; // 'hot' / 'iced' / null
  final String? notes;
  final List<String> addonNames;
  final int addonsPrice;

  TransactionItem({
    required this.id,
    required this.menuItemId,
    required this.menuName,
    required this.unitPrice,
    required this.quantity,
    this.temperature,
    this.notes,
    this.addonNames = const [],
    this.addonsPrice = 0,
  });

  int get lineTotal => (unitPrice + addonsPrice) * quantity;

  Map<String, Object?> toMap(String txId) => {
        'id': id,
        'transaction_id': txId,
        'menu_item_id': menuItemId,
        'menu_name': menuName,
        'unit_price': unitPrice,
        'quantity': quantity,
        'temperature': temperature,
        'notes': notes,
        'addon_names': addonNames.join('|'),
        'addons_price': addonsPrice,
      };

  static TransactionItem fromMap(Map<String, Object?> m) => TransactionItem(
        id: m['id'] as String,
        menuItemId: m['menu_item_id'] as String,
        menuName: m['menu_name'] as String,
        unitPrice: (m['unit_price'] as num).toInt(),
        quantity: (m['quantity'] as num).toInt(),
        temperature: m['temperature'] as String?,
        notes: m['notes'] as String?,
        addonNames: ((m['addon_names'] as String?) ?? '')
            .split('|')
            .where((e) => e.isNotEmpty)
            .toList(),
        addonsPrice: (m['addons_price'] as num?)?.toInt() ?? 0,
      );
}

class TransactionRecord {
  final String id;
  final DateTime createdAt;
  final List<TransactionItem> items;
  final PaymentMethod? paymentMethod;
  final int total;
  final int? cashReceived;
  final String? customerName;
  final String? notes;
  final TransactionStatus status;
  final bool pendingSync;

  // ===== Field pembatalan (void) — null kalau bukan voided =====
  final String? voidReason; // VoidReason.name
  final String? voidNote;
  final DateTime? voidedAt;
  final String? voidedBy;

  TransactionRecord({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.total,
    this.paymentMethod,
    this.cashReceived,
    this.customerName,
    this.notes,
    this.status = TransactionStatus.paid,
    this.pendingSync = true,
    this.voidReason,
    this.voidNote,
    this.voidedAt,
    this.voidedBy,
  });

  int get change =>
      paymentMethod == PaymentMethod.cash && cashReceived != null
          ? (cashReceived! - total)
          : 0;

  bool get isVoided => status == TransactionStatus.voided;

  /// VoidReason enum hasil parse (null kalau tidak ada / tidak dikenal).
  VoidReason? get voidReasonEnum => VoidReason.fromName(voidReason);

  /// Salinan transaksi dalam keadaan dibatalkan.
  TransactionRecord copyAsVoided({
    required VoidReason reason,
    required String note,
    required String by,
    DateTime? at,
  }) =>
      TransactionRecord(
        id: id,
        createdAt: createdAt,
        items: items,
        total: total,
        paymentMethod: paymentMethod,
        cashReceived: cashReceived,
        customerName: customerName,
        notes: notes,
        status: TransactionStatus.voided,
        pendingSync: true,
        voidReason: reason.name,
        voidNote: note,
        voidedAt: at ?? DateTime.now(),
        voidedBy: by,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'total': total,
        'payment_method': paymentMethod?.name,
        'cash_received': cashReceived,
        'customer_name': customerName,
        'notes': notes,
        'status': status.name,
        'pending_sync': pendingSync ? 1 : 0,
        'void_reason': voidReason,
        'void_note': voidNote,
        'voided_at': voidedAt?.toIso8601String(),
        'voided_by': voidedBy,
      };

  static TransactionRecord fromMap(
    Map<String, Object?> m,
    List<TransactionItem> items,
  ) =>
      TransactionRecord(
        id: m['id'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        items: items,
        total: (m['total'] as num).toInt(),
        paymentMethod: m['payment_method'] == null
            ? null
            : PaymentMethod.values
                .firstWhere((e) => e.name == m['payment_method']),
        cashReceived: (m['cash_received'] as num?)?.toInt(),
        customerName: m['customer_name'] as String?,
        notes: m['notes'] as String?,
        status: TransactionStatus.values
            .firstWhere((e) => e.name == m['status']),
        pendingSync: ((m['pending_sync'] as int?) ?? 0) == 1,
        voidReason: m['void_reason'] as String?,
        voidNote: m['void_note'] as String?,
        voidedAt: m['voided_at'] == null
            ? null
            : DateTime.parse(m['voided_at'] as String),
        voidedBy: m['voided_by'] as String?,
      );
}
