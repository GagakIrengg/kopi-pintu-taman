import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/custom_menu.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/transaction.dart' as tx_model;

import '../../../providers/cart_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/low_stock_provider.dart';
import '../../../providers/notified_low_stock_provider.dart';
import '../../../providers/stock_deduction_provider.dart';

import '../widgets/addons_dialog.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/menu_grid.dart';
import '../widgets/notes_dialog.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/receipt_dialog.dart';
import '../widgets/temperature_dialog.dart';
import '../widgets/low_stock_banner.dart';
import '../widgets/custom_menu_dialog.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchCtrl = TextEditingController();

  MenuCategory? _category;

  /// FIX #5 — notif low-stock hanya SEKALI per bahan.
  ///
  /// 1. Reset "ingatan" untuk bahan yang sudah kembali aman (di-restock).
  /// 2. Cari bahan low/out yang BELUM pernah dinotif.
  /// 3. Tampilkan snackbar sekali untuk bahan itu, lalu tandai sudah dinotif.
  ///
  /// Dipakai bersama oleh _onMenuTap (saat pencet menu) dan _checkout
  /// (setelah bayar) supaya perilakunya konsisten & tidak spam.
  void _maybeNotifyLowStock() {
    if (!mounted) return;

    final lowItems = ref.read(lowStockItemsProvider);
    final notifier = ref.read(notifiedLowStockProvider.notifier);
    final alreadyNotified = ref.read(notifiedLowStockProvider);

    // (1) Bahan yang TIDAK lagi low (sudah aman) -> lupakan dari ingatan,
    // supaya kalau nanti turun lagi bisa notif sekali lagi.
    final lowIds = lowItems.map((e) => e.id).toSet();
    for (final id in alreadyNotified) {
      if (!lowIds.contains(id)) {
        notifier.clearNotified(id);
      }
    }

    // (2) Bahan low yang belum pernah dinotif.
    final belumDinotif = lowItems
        .where((it) => !alreadyNotified.contains(it.id))
        .toList();

    if (belumDinotif.isEmpty) return;

    // (3) Tandai + tampilkan sekali.
    for (final it in belumDinotif) {
      notifier.markNotified(it.id);
    }
    final names = belumDinotif.map((e) => e.name).join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Stok menipis: $names. Perlu restock.'),
        action: SnackBarAction(
          label: 'Buka',
          onPressed: () => context.go('/inventory'),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuItemsProvider);

    final cart = ref.watch(cartProvider);

    final heldBillsAsync = ref.watch(heldBillsProvider);

    return menuAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e'),
      ),
      data: (allMenu) {
        final addons = allMenu
            .where((m) => m.category == MenuCategory.addon && m.isAvailable)
            .toList();

        final filtered = allMenu.where((m) {
          if (!m.isAvailable) {
            return false;
          }
          if (_category == null) {
            if (m.category == MenuCategory.addon) {
              return false;
            }
          } else {
            if (m.category != _category) {
              return false;
            }
          }

          if (_searchCtrl.text.isNotEmpty) {
            return m.name
                .toLowerCase()
                .contains(_searchCtrl.text.toLowerCase());
          }

          return true;
        }).toList();

        return Column(
          children: [
            const LowStockBanner(),
            Expanded(
              child: Row(
                children: [
                  // LEFT SIDE
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        _searchAndCategories(),

                        Expanded(
                          child: MenuGrid(
                            items: filtered,
                            onTap: (m) => _onMenuTap(m),
                            onCustomTap: _onCustomMenuTap,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // RIGHT SIDE
                  Expanded(
                    flex: 4,
                    child: _CartPanel(
                      cart: cart,
                      addons: addons,
                      heldBillsAsync: heldBillsAsync,
                      onCheckout: () => _checkout(cart),
                      onHold: () => _holdBill(cart),
                      onOpenHeldBill: _openHeldBill,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchAndCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _catChip(
                  'Semua',
                  _category == null,
                  () => setState(() => _category = null),
                ),

                for (final c in MenuCategory.values)
                  _catChip(
                    c.label,
                    _category == c,
                    () => setState(() => _category = c),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.coffee700,
        backgroundColor: Colors.white,
        side: const BorderSide(
          color: AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: TextStyle(
          color:
              selected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _onMenuTap(MenuItem m) async {
    if (m.isAddon) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add-ons ditambahkan dari item di cart.',
          ),
        ),
      );
      return;
    }

    MenuTemperature? temp;

    if (m.temperature == MenuTemperature.both) {
      temp = await showTemperatureDialog(context, m);

      if (temp == null) return;
    } else if (m.temperature != MenuTemperature.none) {
      temp = m.temperature;
    }

    if (!mounted) return;

    // FIX #5: notif low-stock sekali per bahan (tidak spam tiap pencet menu).
    _maybeNotifyLowStock();

    ref.read(cartProvider.notifier).addItem(
          m,
          temperature: temp,
        );
  }

    Future<void> _onCustomMenuTap() async {

    final result = await showDialog<CustomMenuResult>(

      context: context,

      builder: (_) => const CustomMenuDialog(),

    );

    if (result == null) return;

    if (!mounted) return;

    // Buat MenuItem sintetis (id='custom') lalu masuk lewat addItem biasa.

    // Tidak ada temperature, tidak ada add-on untuk item custom.

    final synthetic = buildCustomMenuItem(

      name: result.name,

      price: result.price,

    );

    ref.read(cartProvider.notifier).addItem(synthetic);

  }

  Future<void> _checkout(CartState cart) async {
    if (cart.items.isEmpty) return;

    final result =
        await showPaymentDialog(context, cart.total);

    if (result == null) return;

    final tx = TransactionRecord(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      items: _toTxItems(cart.items),
      total: cart.total,
      paymentMethod: result.method,
      cashReceived: result.cashReceived,
      customerName: cart.customerName,
      notes: cart.transactionNotes,
      status: TransactionStatus.paid,
    );

    final repo =
        ref.read(transactionRepositoryProvider);

    if (cart.heldBillId != null) {
      await repo.delete(cart.heldBillId!);
    }

    await repo.save(tx);

    // === TAHAP 4: kurangi stok bahan mentah sesuai resep ===
    // Aman: kalau menu belum punya resep, tidak ada stok yang berubah.
    try {
      await ref
          .read(stockDeductionServiceProvider)
          .applyDeduction(cart.items);
    } catch (e) {
      // Jangan gagalkan transaksi hanya karena pengurangan stok error.
      debugPrint('Stock deduction error: $e');
    }
    ref.invalidate(inventoryProvider);
    // =======================================================

    ref.invalidate(salesInRangeProvider);

    ref.invalidate(heldBillsProvider);

    if (!mounted) return;

    await showReceiptDialog(context, tx);

    if (!mounted) return;

    // FIX #5: notif low-stock sekali per bahan (aturan sama dgn pencet menu).
    // Karena pakai ingatan yang sama, bahan yang sudah dinotif tidak akan
    // muncul lagi. Bahan yang BARU jadi low akibat transaksi ini akan
    // dinotif sekali di sini.
    _maybeNotifyLowStock();

    ref.read(cartProvider.notifier).clear();
  }

  Future<void> _holdBill(CartState cart) async {
    if (cart.items.isEmpty) return;

    final id =
        cart.heldBillId ?? const Uuid().v4();

    final tx = TransactionRecord(
      id: id,
      createdAt: DateTime.now(),
      items: _toTxItems(cart.items),
      total: cart.total,
      customerName: cart.customerName,
      notes: cart.transactionNotes,
      status: TransactionStatus.held,
    );

    await ref
        .read(transactionRepositoryProvider)
        .save(tx);

    ref.invalidate(heldBillsProvider);

    ref.read(cartProvider.notifier).clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill berhasil di-hold'),
      ),
    );
  }

  void _openHeldBill(
    tx_model.TransactionRecord tx,
  ) {
    ref
        .read(cartProvider.notifier)
        .loadHeldBill(tx);
  }

  List<TransactionItem> _toTxItems(
    List<CartItem> items,
  ) {
    return items.map((c) {
      return TransactionItem(
        id: const Uuid().v4(),
        menuItemId: c.menuItem.id,
        menuName: c.menuItem.name,
        unitPrice: c.menuItem.price,
        quantity: c.quantity,

        temperature: switch (c.temperature) {
          MenuTemperature.hot => 'hot',
          MenuTemperature.iced => 'iced',
          _ => null,
        },

        notes:
            (c.notes ?? '').isEmpty
                ? null
                : c.notes,

        addonNames:
            c.addons.map((a) => a.name).toList(),

        addonsPrice: c.addons.fold(
          0,
          (s, a) => s + a.price,
        ),
      );
    }).toList();
  }
}

class _CartPanel extends ConsumerStatefulWidget {
  final CartState cart;

  final List<MenuItem> addons;

  final VoidCallback onCheckout;

  final VoidCallback onHold;

  final Function(tx_model.TransactionRecord)
      onOpenHeldBill;

  final AsyncValue<List<tx_model.TransactionRecord>>
      heldBillsAsync;

  const _CartPanel({
    required this.cart,
    required this.addons,
    required this.onCheckout,
    required this.onHold,
    required this.onOpenHeldBill,
    required this.heldBillsAsync,
  });

  @override
  ConsumerState<_CartPanel> createState() =>
      _CartPanelState();
}

class _CartPanelState
    extends ConsumerState<_CartPanel> {
  final _customerCtrl =
      TextEditingController();

  final _txNotesCtrl =
      TextEditingController();

  @override
  void didUpdateWidget(
    covariant _CartPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if ((widget.cart.customerName ?? '') !=
        _customerCtrl.text) {
      _customerCtrl.text =
          widget.cart.customerName ?? '';
    }

    if ((widget.cart.transactionNotes ?? '') !=
        _txNotesCtrl.text) {
      _txNotesCtrl.text =
          widget.cart.transactionNotes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;

    return Container(
      color: Colors.white,

      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.coffee700,
                ),

                const SizedBox(width: 8),

                Text(
                  'Pesanan (${cart.itemCount})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const Spacer(),

                widget.heldBillsAsync.when(
                  data: (heldBills) {
                    if (heldBills.isEmpty) {
                      return const SizedBox();
                    }

                    return PopupMenuButton<
                        tx_model.TransactionRecord>(
                      tooltip: 'Held Bills',

                      onSelected:
                          widget.onOpenHeldBill,

                      itemBuilder: (_) {
                        return heldBills.map((tx) {
                          return PopupMenuItem(
                            value: tx,

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  tx.customerName
                                              ?.isNotEmpty ==
                                          true
                                      ? tx.customerName!
                                      : 'Hold Bill',

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  formatDateTime(
                                      tx.createdAt),

                                  style:
                                      const TextStyle(
                                    fontSize: 11,
                                    color: AppColors
                                        .textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },

                      child: Row(
                        children: [
                          const Text(
                            'Hold Bill',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  AppColors.textMuted,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Container(
                            padding:
                                const EdgeInsets.all(7),

                            decoration:
                                const BoxDecoration(
                              color:
                                  AppColors.warning,
                              shape:
                                  BoxShape.circle,
                            ),

                            child: Text(
                              '${heldBills.length}',

                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },

                  loading: () =>
                      const SizedBox(),

                  error: (_, __) =>
                      const SizedBox(),
                ),

                const SizedBox(width: 10),

                if (cart.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(cartProvider.notifier)
                        .clear(),

                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: AppColors.danger,
                      size: 18,
                    ),

                    label: const Text(
                      'Clear',
                      style: TextStyle(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),

                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.coffee_outlined,
                            size: 56,
                            color:
                                AppColors.textMuted,
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Belum ada pesanan',
                            style: TextStyle(
                              color: AppColors
                                  .textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,

                    itemBuilder: (_, i) {
                      final c = cart.items[i];

                      return CartItemTile(
                        item: c,

                        onInc: () => ref
                            .read(cartProvider.notifier)
                            .increment(c.lineId),

                        onDec: () => ref
                            .read(cartProvider.notifier)
                            .decrement(c.lineId),

                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .remove(c.lineId),

                        onEditNotes: () =>
                            _editLine(c.lineId, c),
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(10),

            child: Column(
              children: [
                TextField(
                  controller: _customerCtrl,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Nama Customer (opsional)',
                    isDense: true,
                  ),

                  onChanged: (v) => ref
                      .read(cartProvider.notifier)
                      .setCustomer(v),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: _txNotesCtrl,

                  maxLines: 2,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Catatan transaksi (opsional)',
                    isDense: true,
                  ),

                  onChanged: (v) => ref
                      .read(cartProvider.notifier)
                      .setNotes(v),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),

            color: AppColors.cream100,

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        color:
                            AppColors.textMuted,
                      ),
                    ),

                    Text(
                      formatRupiah(
                          cart.subtotal),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      formatRupiah(cart.total),

                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 18,
                        color:
                            AppColors.coffee700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            cart.items.isEmpty
                                ? null
                                : widget.onHold,

                        icon: const Icon(
                          Icons
                              .pause_circle_outline,
                        ),

                        label:
                            const Text('Hold'),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      flex: 2,

                      child:
                          ElevatedButton.icon(
                        onPressed:
                            cart.items.isEmpty
                                ? null
                                : widget
                                    .onCheckout,

                        icon: const Icon(
                          Icons.point_of_sale,
                        ),

                        label:
                            const Text('Bayar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editLine(
    String lineId,
    CartItem c,
  ) async {
    final action =
        await showModalBottomSheet<String>(
      context: context,

      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            ListTile(
              leading:
                  const Icon(Icons.edit_note),

              title:
                  const Text('Catatan item'),

              onTap: () =>
                  Navigator.pop(context, 'notes'),
            ),

            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
              ),

              title:
                  const Text('Add-ons'),

              onTap: () =>
                  Navigator.pop(
                context,
                'addons',
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (action == 'notes') {
      final v =
          await showItemNotesDialog(
        context,
        c.notes,
      );

      if (!mounted) return;

      if (v != null) {
        ref
            .read(cartProvider.notifier)
            .updateLineNotes(
              lineId,
              v.isEmpty ? null : v,
            );
      }
    }

    else if (action == 'addons') {
      final r = await showAddonsDialog(
        context,
        widget.addons,
        initial: c.addons,
      );

      if (!mounted) return;

      if (r != null) {
        c.addons
          ..clear()
          ..addAll(r);

        ref
            .read(cartProvider.notifier)
            .updateLineNotes(
              lineId,
              c.notes,
            );
      }
    }
  }
}
