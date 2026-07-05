import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/cart_item.dart';
import '../data/models/menu_item.dart';
import '../data/models/transaction.dart';

class CartState {
  final List<CartItem> items;
  final String? customerName;
  final String? transactionNotes;
  final String? heldBillId;

  const CartState({
    this.items = const [],
    this.customerName,
    this.transactionNotes,
    this.heldBillId,
  });

  int get subtotal => items.fold(0, (s, i) => s + i.lineTotal);

  int get total => subtotal;

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? customerName,
    String? transactionNotes,
    String? heldBillId,
    bool clearCustomer = false,
    bool clearNotes = false,
    bool clearHeldId = false,
  }) {
    return CartState(
      items: items ?? this.items,
      customerName:
          clearCustomer ? null : (customerName ?? this.customerName),
      transactionNotes:
          clearNotes ? null : (transactionNotes ?? this.transactionNotes),
      heldBillId: clearHeldId ? null : (heldBillId ?? this.heldBillId),
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  static const _uuid = Uuid();

  void addItem(
    MenuItem item, {
    MenuTemperature? temperature,
    List<MenuItem> addons = const [],
    String? notes,
  }) {
    final newItem = CartItem(
      lineId: _uuid.v4(),
      menuItem: item,
      temperature: temperature,
      addons: List.of(addons),
      notes: notes,
    );

    state = state.copyWith(
      items: [...state.items, newItem],
    );
  }

  void increment(String lineId) {
    final updated = <CartItem>[];

    for (final i in state.items) {
      if (i.lineId == lineId) {
        i.quantity++;
      }

      updated.add(i);
    }

    state = state.copyWith(items: updated);
  }

  void decrement(String lineId) {
    final updated = <CartItem>[];

    for (final i in state.items) {
      if (i.lineId == lineId) {
        if (i.quantity > 1) {
          i.quantity--;
          updated.add(i);
        }
      } else {
        updated.add(i);
      }
    }

    state = state.copyWith(items: updated);
  }

  void remove(String lineId) {
    state = state.copyWith(
      items: state.items.where((i) => i.lineId != lineId).toList(),
    );
  }

  void updateLineNotes(String lineId, String? notes) {
    final updated = <CartItem>[];

    for (final i in state.items) {
      if (i.lineId == lineId) {
        i.notes = notes;
      }

      updated.add(i);
    }

    state = state.copyWith(items: updated);
  }

  void setCustomer(String? v) {
    state = state.copyWith(
      customerName: v,
      clearCustomer: v == null,
    );
  }

  void setNotes(String? v) {
    state = state.copyWith(
      transactionNotes: v,
      clearNotes: v == null,
    );
  }

  void clear() {
    state = const CartState();
  }

  /// Load held bill langsung ke cart
  void loadHeldBill(TransactionRecord tx) {
    final items = tx.items.map((item) {
      return CartItem(
        lineId: item.id,

        menuItem: MenuItem(
          id: item.menuItemId,
          name: item.menuName,
          price: item.unitPrice,

          // fallback category
          category: MenuCategory.coffee,

          temperature: MenuTemperature.none,
        ),

        quantity: item.quantity,

        temperature: switch (item.temperature) {
          'hot' => MenuTemperature.hot,
          'iced' => MenuTemperature.iced,
          _ => null,
        },

        notes: item.notes,

        // sementara kosong dulu
        addons: [],
      );
    }).toList();

    state = CartState(
      items: items,
      customerName: tx.customerName,
      transactionNotes: tx.notes,
      heldBillId: tx.id,
    );
  }

  /// versi lama (tetap dipakai kalau dibutuhkan)
  void loadFromHeld(
    TransactionRecord tx,
    List<MenuItem> menuLookup,
  ) {
    final items = <CartItem>[];

    for (final ti in tx.items) {
      final menu = menuLookup.firstWhere(
        (m) => m.id == ti.menuItemId,
        orElse: () => MenuItem(
          id: ti.menuItemId,
          name: ti.menuName,
          price: ti.unitPrice,
          category: MenuCategory.coffee,
          temperature: MenuTemperature.none,
        ),
      );

      final addons = ti.addonNames
          .map(
            (n) => menuLookup.firstWhere(
              (m) => m.name == n && m.isAddon,
              orElse: () => MenuItem(
                id: 'a-${n.hashCode}',
                name: n,
                price: 0,
                category: MenuCategory.addon,
                temperature: MenuTemperature.none,
              ),
            ),
          )
          .toList();

      items.add(
        CartItem(
          lineId: _uuid.v4(),
          menuItem: menu,
          quantity: ti.quantity,

          temperature: switch (ti.temperature) {
            'hot' => MenuTemperature.hot,
            'iced' => MenuTemperature.iced,
            _ => null,
          },

          notes: ti.notes,
          addons: addons,
        ),
      );
    }

    state = CartState(
      items: items,
      customerName: tx.customerName,
      transactionNotes: tx.notes,
      heldBillId: tx.id,
    );
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>(
  (_) => CartNotifier(),
);